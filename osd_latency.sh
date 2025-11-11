#!/bin/bash

# Ceph OSD Latency Monitor
# Tracks OSD latencies over time and identifies problematic OSDs

# Configuration
SAMPLE_INTERVAL=5      # Seconds between samples
SAMPLE_COUNT=20        # Number of samples to collect (0 for infinite)
WARN_THRESHOLD=50      # Latency in ms to consider warning level
CRIT_THRESHOLD=100     # Latency in ms to consider critical
HIGH_LAT_PERCENT=30    # Percentage of samples that must be high to flag OSD

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Data storage
declare -A osd_samples
declare -A osd_high_count
declare -A osd_total_count
declare -A osd_sum
declare -A osd_max
declare -A osd_last

# Clean exit on Ctrl+C
trap cleanup INT

cleanup() {
    echo -e "\n\n${BOLD}=== Final OSD Latency Report ===${NC}"
    generate_report
    exit 0
}

collect_sample() {
    local sample_num=$1
    
    # Get current OSD performance data
    while IFS= read -r line; do
        # Skip header line
        [[ "$line" =~ ^osd ]] && continue
        [[ -z "$line" ]] && continue
        
        # Parse OSD ID and latencies
        osd_id=$(echo "$line" | awk '{print $1}')
        fs_apply_lat=$(echo "$line" | awk '{print $2}')
        fs_commit_lat=$(echo "$line" | awk '{print $3}')
        
        # Skip if we couldn't parse properly
        [[ -z "$osd_id" || -z "$fs_commit_lat" ]] && continue
        
        # Use commit latency (typically the higher of the two)
        latency=$fs_commit_lat
        
        # Initialize OSD if first time seeing it
        if [[ -z "${osd_total_count[$osd_id]}" ]]; then
            osd_samples[$osd_id]=""
            osd_high_count[$osd_id]=0
            osd_total_count[$osd_id]=0
            osd_sum[$osd_id]=0
            osd_max[$osd_id]=0
        fi
        
        # Store sample
        osd_samples[$osd_id]="${osd_samples[$osd_id]} $latency"
        osd_last[$osd_id]=$latency
        osd_total_count[$osd_id]=$((${osd_total_count[$osd_id]} + 1))
        osd_sum[$osd_id]=$((${osd_sum[$osd_id]} + $latency))
        
        # Track max latency
        if (( latency > ${osd_max[$osd_id]} )); then
            osd_max[$osd_id]=$latency
        fi
        
        # Count high latency samples
        if (( latency >= WARN_THRESHOLD )); then
            osd_high_count[$osd_id]=$((${osd_high_count[$osd_id]} + 1))
        fi
        
    done < <(ceph osd perf 2>/dev/null | grep -v "^osd")
}

display_current_status() {
    local sample_num=$1
    
    # Clear screen for better readability
    clear
    
    echo -e "${BOLD}=== Ceph OSD Latency Monitor ===${NC}"
    echo -e "Sample: $sample_num | Interval: ${SAMPLE_INTERVAL}s | Thresholds: WARN>${WARN_THRESHOLD}ms CRIT>${CRIT_THRESHOLD}ms\n"
    
    # Display header
    printf "${BOLD}%-8s %-12s %-12s %-12s %-12s %-8s %s${NC}\n" \
           "OSD" "Current(ms)" "Avg(ms)" "Max(ms)" "High%" "Samples" "Status"
    printf "%-8s %-12s %-12s %-12s %-12s %-8s %s\n" \
           "---" "----------" "-------" "-------" "------" "-------" "------"
    
    # Sort by current latency and display
    for osd_id in $(for osd in "${!osd_last[@]}"; do
        echo "$osd ${osd_last[$osd]}"
    done | sort -k2 -rn | head -20 | awk '{print $1}'); do
        
        current_lat=${osd_last[$osd_id]}
        total_count=${osd_total_count[$osd_id]}
        
        # Calculate average
        if (( total_count > 0 )); then
            avg_lat=$(( ${osd_sum[$osd_id]} / total_count ))
            high_percent=$(( (${osd_high_count[$osd_id]} * 100) / total_count ))
        else
            avg_lat=0
            high_percent=0
        fi
        
        max_lat=${osd_max[$osd_id]}
        
        # Determine status and color
        status=""
        color=""
        
        if (( current_lat >= CRIT_THRESHOLD )) || (( avg_lat >= CRIT_THRESHOLD )); then
            status="CRITICAL"
            color=$RED
        elif (( high_percent >= HIGH_LAT_PERCENT )); then
            status="DEGRADED"
            color=$YELLOW
        elif (( current_lat >= WARN_THRESHOLD )) || (( avg_lat >= WARN_THRESHOLD )); then
            status="WARNING"
            color=$YELLOW
        else
            status="OK"
            color=$GREEN
        fi
        
        # Apply color to current latency if high
        current_display=$current_lat
        if (( current_lat >= WARN_THRESHOLD )); then
            current_display="${color}${current_lat}${NC}"
        fi
        
        printf "%-8s %-12b %-12s %-12s %-12s %-8s ${color}%-12s${NC}\n" \
               "$osd_id" "$current_display" "$avg_lat" "$max_lat" "${high_percent}%" "$total_count" "$status"
    done
}

generate_report() {
    echo -e "\n${BOLD}Problematic OSDs (sorted by severity):${NC}\n"
    
    # Create severity scores and identify problematic OSDs
    declare -A severity_scores
    
    for osd_id in "${!osd_total_count[@]}"; do
        total_count=${osd_total_count[$osd_id]}
        
        if (( total_count == 0 )); then
            continue
        fi
        
        avg_lat=$(( ${osd_sum[$osd_id]} / total_count ))
        high_percent=$(( (${osd_high_count[$osd_id]} * 100) / total_count ))
        max_lat=${osd_max[$osd_id]}
        
        # Calculate severity score (higher = worse)
        # Weight: 40% average latency, 30% high percentage, 30% max latency
        severity=$(( (avg_lat * 40 + high_percent * 30 + max_lat * 3) / 10 ))
        severity_scores[$osd_id]=$severity
        
        # Only report OSDs with issues
        if (( avg_lat >= WARN_THRESHOLD )) || (( high_percent >= HIGH_LAT_PERCENT )) || (( max_lat >= CRIT_THRESHOLD )); then
            echo -e "${BOLD}OSD.$osd_id${NC}"
            echo -e "  Average Latency: ${avg_lat}ms"
            echo -e "  Max Latency: ${max_lat}ms"
            echo -e "  High Latency Rate: ${high_percent}% (${osd_high_count[$osd_id]}/${total_count} samples)"
            echo -e "  Severity Score: ${severity}"
            
            # Provide recommendations
            if (( avg_lat >= CRIT_THRESHOLD )); then
                echo -e "  ${RED}⚠ CRITICAL:${NC} Consistently high latency - investigate immediately"
            elif (( high_percent >= 50 )); then
                echo -e "  ${YELLOW}⚠ WARNING:${NC} Frequent latency spikes - possible hardware or network issue"
            elif (( max_lat >= CRIT_THRESHOLD )); then
                echo -e "  ${YELLOW}⚠ WARNING:${NC} Occasional severe latency spikes"
            fi
            
            # Show recent samples for context
            echo -e "  Recent samples:${osd_samples[$osd_id]}"
            echo
        fi
    done
    
    # Summary statistics
    echo -e "\n${BOLD}Summary Statistics:${NC}"
    echo -e "Total OSDs monitored: ${#osd_total_count[@]}"
    
    problem_count=0
    critical_count=0
    
    for osd_id in "${!osd_total_count[@]}"; do
        total_count=${osd_total_count[$osd_id]}
        if (( total_count == 0 )); then
            continue
        fi
        
        avg_lat=$(( ${osd_sum[$osd_id]} / total_count ))
        high_percent=$(( (${osd_high_count[$osd_id]} * 100) / total_count ))
        
        if (( avg_lat >= WARN_THRESHOLD )) || (( high_percent >= HIGH_LAT_PERCENT )); then
            problem_count=$((problem_count + 1))
        fi
        
        if (( avg_lat >= CRIT_THRESHOLD )); then
            critical_count=$((critical_count + 1))
        fi
    done
    
    echo -e "OSDs with issues: $problem_count"
    echo -e "OSDs critical: $critical_count"
}

# Main monitoring loop
echo -e "${BOLD}Starting Ceph OSD Latency Monitoring...${NC}"
echo "Press Ctrl+C to stop and see final report"
echo

sample_num=0

while true; do
    sample_num=$((sample_num + 1))
    
    # Collect sample
    collect_sample $sample_num
    
    # Display current status
    display_current_status $sample_num
    
    # Check if we've reached sample count limit
    if [[ $SAMPLE_COUNT -gt 0 ]] && [[ $sample_num -ge $SAMPLE_COUNT ]]; then
        echo -e "\n\nReached sample count limit ($SAMPLE_COUNT samples)"
        generate_report
        break
    fi
    
    # Wait for next sample
    sleep $SAMPLE_INTERVAL
done
