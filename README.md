# Ceph OSD Latency Monitor

A real-time monitoring tool for identifying Ceph OSDs with performance issues by tracking latency patterns over time.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Ceph](https://img.shields.io/badge/ceph-compatible-brightgreen.svg)
![Bash](https://img.shields.io/badge/bash-4.0%2B-orange.svg)

## 📋 Overview

This tool continuously monitors Ceph OSD latencies and identifies problematic OSDs that may be impacting cluster performance. Unlike single-point checks, it tracks latency patterns over time to distinguish between occasional spikes and persistent performance issues.

### Key Features

- 🔄 **Real-time monitoring** with configurable sampling intervals
- 📊 **Statistical analysis** of latency patterns per OSD
- 🎨 **Color-coded output** for quick issue identification
- 📈 **Severity scoring** to prioritize problem OSDs
- 💾 **Detailed reporting** with actionable recommendations
- ⚡ **Lightweight** - minimal impact on cluster performance

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/ceph-osd-latency-monitor.git
cd ceph-osd-latency-monitor

# Make the script executable
chmod +x monitor_osd_latency.sh

# Run with default settings
./monitor_osd_latency.sh

# Run with custom settings
SAMPLE_COUNT=50 WARN_THRESHOLD=30 ./monitor_osd_latency.sh
```

## 📦 Requirements

- **Ceph cluster** (Luminous or newer)
- **Bash 4.0+**
- **Ceph admin privileges** (ability to run `ceph osd perf`)
- **Linux environment** with standard tools (awk, grep, sort)

## 🛠️ Installation

### Option 1: Direct Download

```bash
wget https://raw.githubusercontent.com/yourusername/ceph-osd-latency-monitor/main/monitor_osd_latency.sh
chmod +x monitor_osd_latency.sh
```

### Option 2: Clone Repository

```bash
git clone https://github.com/yourusername/ceph-osd-latency-monitor.git
cd ceph-osd-latency-monitor
chmod +x monitor_osd_latency.sh
```

### Option 3: System-wide Installation

```bash
sudo cp monitor_osd_latency.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitor_osd_latency.sh
```

## 📖 Usage

### Basic Monitoring

```bash
# Monitor with default settings (20 samples, 5-second intervals)
./monitor_osd_latency.sh

# Monitor continuously until Ctrl+C
SAMPLE_COUNT=0 ./monitor_osd_latency.sh

# Quick 1-minute assessment (12 samples, 5-second intervals)
SAMPLE_COUNT=12 ./monitor_osd_latency.sh
```

### Advanced Usage

```bash
# Monitor with aggressive thresholds for NVMe clusters
WARN_THRESHOLD=20 CRIT_THRESHOLD=50 ./monitor_osd_latency.sh

# Long-term monitoring with less frequent sampling
SAMPLE_INTERVAL=30 SAMPLE_COUNT=120 ./monitor_osd_latency.sh

# Export results to a file
./monitor_osd_latency.sh 2>&1 | tee osd_latency_report.txt
```

### Running as a Service

See [systemd service file](monitor-osd-latency.service) for running continuous monitoring.

## ⚙️ Configuration

Configure the script by setting environment variables or editing the script directly:

| Variable | Default | Description |
|----------|---------|-------------|
| `SAMPLE_INTERVAL` | 5 | Seconds between samples |
| `SAMPLE_COUNT` | 20 | Number of samples to collect (0 for infinite) |
| `WARN_THRESHOLD` | 50 | Latency in ms to trigger warning |
| `CRIT_THRESHOLD` | 100 | Latency in ms to trigger critical alert |
| `HIGH_LAT_PERCENT` | 30 | Percentage of high samples to flag OSD as degraded |

### Configuration Examples

```bash
# For HDD-based clusters (higher thresholds)
export WARN_THRESHOLD=100
export CRIT_THRESHOLD=200

# For NVMe-based clusters (lower thresholds)
export WARN_THRESHOLD=20
export CRIT_THRESHOLD=50

# For hybrid clusters (balanced thresholds)
export WARN_THRESHOLD=50
export CRIT_THRESHOLD=100
```

## 📊 Understanding the Output

### Live Monitoring Display

```
=== Ceph OSD Latency Monitor ===
Sample: 15 | Interval: 5s | Thresholds: WARN>50ms CRIT>100ms

OSD      Current(ms)  Avg(ms)      Max(ms)      High%        Samples  Status
---      ----------   -------      -------      ------       -------  ------
384      156          89           156          45%          15       CRITICAL
78       95           62           95           38%          15       DEGRADED
312      42           31           78           20%          15       WARNING
579      17           15           23           0%           15       OK
```

### Status Indicators

- **OK** (Green): Operating normally
- **WARNING** (Yellow): Approaching threshold limits
- **DEGRADED** (Yellow): Frequent high latency occurrences
- **CRITICAL** (Red): Severe latency issues requiring immediate attention

### Final Report Sections

1. **Problematic OSDs**: Detailed breakdown of OSDs with issues
2. **Severity Score**: Weighted score based on avg latency (40%), high latency frequency (30%), and max latency (30%)
3. **Recommendations**: Specific actions based on observed patterns
4. **Summary Statistics**: Cluster-wide overview

## 🔍 Troubleshooting Common Issues

### High Latency Patterns and Causes

| Pattern | Likely Cause | Recommended Action |
|---------|--------------|-------------------|
| Consistent high latency | Failing disk, bad controller | Check SMART data, consider OSD replacement |
| Periodic spikes | Network congestion, CPU C-states | Check network stats, disable deep C-states |
| Random spikes | Memory pressure, competing workloads | Check system resources, isolate workloads |
| Gradual increase | Disk fragmentation, aging hardware | Run defrag, plan hardware refresh |

### Common Commands for Investigation

```bash
# Check specific OSD details
ceph daemon osd.384 perf dump

# View OSD disk utilization
ceph osd df tree

# Check for slow operations
ceph daemon osd.384 dump_ops_in_flight

# Examine OSD logs
journalctl -u ceph-osd@384 -n 100

# Check disk SMART data
smartctl -a /dev/sdX
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines

1. Keep the script POSIX-compliant where possible
2. Test on multiple Ceph versions (Luminous+)
3. Add comments for complex logic
4. Update documentation for new features

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Ceph community for the excellent distributed storage system
- Contributors and users who provided feedback and improvements

## 📚 Additional Resources

- [Ceph OSD Performance Tuning Guide](https://docs.ceph.com/en/latest/rados/troubleshooting/troubleshooting-osd/)
- [Understanding Ceph Performance](https://docs.ceph.com/en/latest/rados/operations/performance/)
- [Linux CPU C-States Guide](https://www.kernel.org/doc/html/latest/admin-guide/pm/cpuidle.html)

## 📧 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/ceph-osd-latency-monitor/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/ceph-osd-latency-monitor/discussions)

---

**Note**: This tool is not officially affiliated with or endorsed by the Ceph project.
