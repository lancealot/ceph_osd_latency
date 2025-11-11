# Changelog

All notable changes to the Ceph OSD Latency Monitor will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Support for custom output formats (JSON, CSV)
- Integration with Prometheus/Grafana
- Historical data persistence
- Email alerting for critical OSDs

## [1.0.0] - 2024-01-15

### Added
- Initial release of Ceph OSD Latency Monitor
- Real-time monitoring with configurable intervals
- Color-coded status indicators
- Severity scoring algorithm
- Final report generation with recommendations
- Support for environment variable configuration
- Systemd service file for continuous monitoring
- Comprehensive documentation

### Features
- Track per-OSD latency statistics (current, average, max)
- Identify consistently problematic OSDs
- Differentiate between occasional spikes and persistent issues
- Provide actionable recommendations based on patterns
- Support for both interactive and batch monitoring modes

### Configuration Options
- Customizable warning and critical thresholds
- Adjustable sampling intervals and count
- Configurable high latency percentage threshold

## [0.9.0-beta] - 2024-01-01

### Added
- Beta release for testing
- Basic monitoring functionality
- Simple reporting

### Known Issues
- Output formatting issues on some terminals
- May miss some OSDs during rapid topology changes

---

## Release Notes

### Version 1.0.0
This is the first stable release of the Ceph OSD Latency Monitor. It has been tested with:
- Ceph Luminous (12.x)
- Ceph Mimic (13.x)
- Ceph Nautilus (14.x)
- Ceph Octopus (15.x)
- Ceph Pacific (16.x)
- Ceph Quincy (17.x)
- Ceph Reef (18.x)

### Upgrade Instructions
If upgrading from beta versions:
1. Stop any running monitor processes
2. Replace the script with the new version
3. Update any systemd service files
4. Restart monitoring services
