# Contributing to Ceph OSD Latency Monitor

First off, thank you for considering contributing to this project! 👍

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to:
- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

1. **Clear title and description**
2. **Steps to reproduce**
3. **Expected behavior**
4. **Actual behavior**
5. **System information:**
   - Ceph version (`ceph --version`)
   - OS distribution and version
   - Bash version (`bash --version`)
6. **Relevant logs or error messages**

### 💡 Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

1. **Use case** - Why is this enhancement needed?
2. **Proposed solution** - How should it work?
3. **Alternatives considered** - What other solutions did you consider?
4. **Additional context** - Screenshots, mockups, etc.

### 🔧 Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages (`git commit -m 'Add some AmazingFeature'`)
6. Push to your branch (`git push origin feature/AmazingFeature`)
7. Open a Pull Request

## Development Setup

### Prerequisites

```bash
# Install development dependencies
sudo apt-get install shellcheck  # For bash linting
sudo apt-get install bats        # For bash testing (optional)
```

### Local Development

1. **Clone your fork:**
```bash
git clone https://github.com/yourusername/ceph-osd-latency-monitor.git
cd ceph-osd-latency-monitor
```

2. **Create a test environment:**
```bash
# Option 1: Use a Ceph development cluster
# Option 2: Create mock data for testing (see tests/mock_data.sh)
```

3. **Make changes and test:**
```bash
# Run shellcheck for linting
shellcheck monitor_osd_latency.sh

# Test with mock data
./tests/run_tests.sh

# Test on real cluster (be careful!)
./monitor_osd_latency.sh
```

## Style Guidelines

### Bash Script Standards

1. **Use shellcheck** - All scripts must pass shellcheck without warnings
2. **POSIX compliance** where possible (note exceptions for bash 4+ features)
3. **Clear variable names** - Use descriptive names in UPPER_CASE for globals
4. **Comments** - Add comments for complex logic
5. **Error handling** - Always check command return values
6. **Quotes** - Quote all variable expansions unless there's a specific reason not to

### Code Structure

```bash
# Good example
check_osd_latency() {
    local osd_id="$1"
    local threshold="$2"
    
    # Validate inputs
    if [[ -z "$osd_id" ]]; then
        echo "Error: OSD ID required" >&2
        return 1
    fi
    
    # Check latency
    local latency
    latency=$(get_osd_latency "$osd_id")
    
    if (( latency > threshold )); then
        return 1
    fi
    return 0
}
```

### Commit Messages

Follow conventional commit format:

```
type(scope): subject

body (optional)

footer (optional)
```

Types: feat, fix, docs, style, refactor, test, chore

Example:
```
feat(monitor): add JSON output format

Added support for JSON output format to facilitate integration
with monitoring systems like Prometheus and Grafana.

Closes #123
```

## Testing

### Running Tests

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test
./tests/test_latency_calculation.sh

# Test with different Ceph versions
CEPH_VERSION=luminous ./tests/run_tests.sh
```

### Adding Tests

Create new test files in the `tests/` directory:

```bash
#!/usr/bin/env bats

@test "calculate average latency" {
    source ./monitor_osd_latency.sh
    
    # Test data
    osd_sum[0]=1000
    osd_total_count[0]=10
    
    # Calculate
    result=$(calculate_average 0)
    
    # Assert
    [ "$result" -eq 100 ]
}
```

## Documentation

### Updating Documentation

- Update README.md for user-facing changes
- Update inline script comments for code changes
- Add examples for new features
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/)

### Documentation Standards

1. **Clear and concise** - Avoid unnecessary jargon
2. **Examples** - Include practical examples
3. **Formatting** - Use markdown properly
4. **Completeness** - Document all options and features

## 🎯 Focus Areas

Current areas where contributions are especially welcome:

1. **Performance optimizations** for large clusters (1000+ OSDs)
2. **Integration** with monitoring systems (Prometheus, Grafana)
3. **Additional metrics** (network latency, CPU correlation)
4. **Automated remediation** suggestions
5. **Historical data** persistence and analysis
6. **Testing** on various Ceph versions and configurations

## 📝 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🤝 Recognition

Contributors will be recognized in:
- The project README
- Release notes
- The AUTHORS file (for significant contributions)

## Questions?

Feel free to:
- Open an issue for discussion
- Start a discussion in GitHub Discussions
- Contact the maintainers

Thank you for helping improve Ceph OSD Latency Monitor! 🚀
