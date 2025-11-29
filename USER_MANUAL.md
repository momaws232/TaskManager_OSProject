# System Monitoring Solution - User Manual

## Arab Academy for Science, Technology & Maritime Transport
### Operating Systems - Project 12

---

## Table of Contents
1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Using the Command Line Interface](#using-the-command-line-interface)
4. [Using the Interactive Dashboard](#using-the-interactive-dashboard)
5. [Using the Web Interface](#using-the-web-interface)
6. [Understanding Reports](#understanding-reports)
7. [Working with Historical Data](#working-with-historical-data)
8. [Alert System](#alert-system)
9. [Best Practices](#best-practices)
10. [FAQ](#faq)

---

## Introduction

The System Monitoring Solution is a comprehensive tool designed to collect, analyze, and report on various system metrics including CPU, memory, disk, GPU, network, and system load performance.

### Key Features
- ✅ Real-time system monitoring
- ✅ Historical data tracking
- ✅ Automated report generation
- ✅ Alert system for critical events
- ✅ Interactive GUI dashboard
- ✅ Web-based visualization
- ✅ Docker containerization support
- ✅ Multiple output formats (JSON, Markdown, HTML)

---

## Getting Started

### First Run

1. **Navigate to the project directory:**
   ```bash
   cd OSProject
   ```

2. **Run your first monitoring cycle:**
   ```bash
   ./monitor.sh monitor
   ```

3. **View the results:**
   ```bash
   ls logs/
   ls data/
   ```

---

## Using the Command Line Interface

### Basic Commands

#### 1. Monitor All Components
Collects data from CPU, memory, disk, GPU, network, and system load:
```bash
./monitor.sh monitor
```

**Output:**
- Creates log files in `logs/`
- Stores metrics in `data/`
- Displays status messages

#### 2. Generate Comprehensive Report
Creates a detailed markdown report:
```bash
./monitor.sh report
```

**Output:**
- Generates `reports/system_report_TIMESTAMP.md`
- Includes all current metrics
- Lists warnings and errors
- Provides system overview

#### 3. Continuous Monitoring
Runs monitoring every 60 seconds:
```bash
./monitor.sh continuous
```

**To stop:** Press `Ctrl+C`

**Use case:** Long-term monitoring, tracking system behavior over time

#### 4. Monitor Individual Components

##### CPU Monitoring
```bash
./monitor.sh cpu
```
**Shows:**
- CPU usage percentage
- Number of cores
- Load average
- Temperature (if available)

##### Memory Monitoring
```bash
./monitor.sh memory
```
**Shows:**
- Total/used/free memory
- Memory usage percentage
- Swap usage

##### Disk Monitoring
```bash
./monitor.sh disk
```
**Shows:**
- Disk usage percentage
- Total/used/available space
- SMART status (if available)

##### GPU Monitoring
```bash
./monitor.sh gpu
```
**Shows:**
- GPU name/model
- GPU utilization
- Memory usage
- Temperature

##### Network Monitoring
```bash
./monitor.sh network
```
**Shows:**
- Primary network interface
- IP address
- Bytes/packets transferred
- Connection status

##### System Load Monitoring
```bash
./monitor.sh system
```
**Shows:**
- Uptime
- Load averages (1, 5, 15 min)
- Process counts
- Logged users

---

## Using the Interactive Dashboard

### Launching the Dashboard

```bash
./dashboard.sh
```

### Dashboard Menu Options

#### Main Menu Structure
```
┌─────────────────────────────────────────┐
│ System Monitoring Dashboard             │
│ AASTMT OS Project                       │
├─────────────────────────────────────────┤
│ 1.  View CPU Metrics                    │
│ 2.  View Memory Metrics                 │
│ 3.  View Disk Metrics                   │
│ 4.  View GPU Metrics                    │
│ 5.  View Network Metrics                │
│ 6.  View System Load Metrics            │
│ 7.  Run Full System Scan                │
│ 8.  Generate Report                     │
│ 9.  View Reports                        │
│ 10. View Logs                           │
│ 11. View Historical Data                │
│ 12. Configure Thresholds                │
│ 13. Start Continuous Monitoring         │
│ 14. Stop Continuous Monitoring          │
│ 15. About                               │
│ 16. Exit                                │
└─────────────────────────────────────────┘
```

### Navigation
- **Use Arrow Keys** ↑↓ to move through menu
- **Press Enter** to select an option
- **Press Esc** to go back (in sub-menus)
- **Tab** to move between buttons

### Key Functions

#### Option 7: Run Full System Scan
- Collects data from all components
- Displays progress messages
- Shows summary upon completion

#### Option 8: Generate Report
- Creates a new markdown report
- Shows the file path when done
- Report includes all current metrics

#### Option 9: View Reports
- Lists all generated reports
- Sorted by date (newest first)
- Select a report to view its contents

#### Option 10: View Logs
- Shows all log files
- Select a log to view
- Displays most recent entries

#### Option 11: View Historical Data
- Access CSV data files
- Choose metric type to view
- Shows time-series data

#### Option 12: Configure Thresholds
- Set custom alert thresholds
- Modify CPU, memory, disk limits
- Changes apply immediately

#### Option 13: Start Continuous Monitoring
- Runs monitoring in background
- Records process ID (PID)
- Creates continuous log file

#### Option 14: Stop Continuous Monitoring
- Stops background monitoring
- Shows PID of stopped process
- Preserves collected data

---

## Using the Web Interface

### Starting the Web Server

#### Method 1: Docker Compose
```bash
docker-compose --profile web up -d monitor-web
```

#### Method 2: Direct Python
```bash
python3 web/server.py
```

### Accessing the Interface

1. Open your web browser
2. Navigate to: `http://localhost:8080`
3. The dashboard will load automatically

### Web Dashboard Features

#### Real-Time Metrics Display
The dashboard shows 6 metric cards:
1. **CPU Card**: Usage, cores, load, temperature
2. **Memory Card**: Usage, total, used, available
3. **Disk Card**: Usage, capacity, SMART status
4. **GPU Card**: Device, usage, memory, temperature
5. **Network Card**: Status, interface, IP, transfer stats
6. **System Load Card**: Load average, processes, uptime

#### Auto-Refresh
- Automatically updates every 30 seconds
- Shows last update time
- No manual refresh needed

#### Alerts Section
- Displays recent warnings and errors
- Color-coded by severity
- Shows last 10 alerts

### API Endpoints

The web server provides REST API endpoints:

```bash
# Get latest metrics
curl http://localhost:8080/api/metrics/latest

# Get CPU history
curl http://localhost:8080/api/metrics/history/cpu

# Get all reports
curl http://localhost:8080/api/reports

# Get specific report
curl http://localhost:8080/api/reports/system_report_20241129_120000.md

# Get all logs
curl http://localhost:8080/api/logs

# Get specific log
curl http://localhost:8080/api/logs/monitor_20241129_120000.log

# Get recent alerts
curl http://localhost:8080/api/alerts

# Get statistics
curl http://localhost:8080/api/stats

# Health check
curl http://localhost:8080/health
```

---

## Understanding Reports

### Report Structure

```markdown
# System Monitoring Report

## Report Information
- Generated: 2024-11-29 14:30:00
- Hostname: server-01
- OS: Linux 5.15.0

## System Overview

### CPU Metrics
{
  "timestamp": "20241129_143000",
  "cpu_usage": "45.2",
  "cpu_cores": "8",
  "load_average": "2.15, 1.98, 1.87",
  "temperature": "58.0"
}

### Memory Metrics
...

### Disk Metrics
...

## Alerts and Warnings

### Warnings
[2024-11-29 14:25:00] [WARNING] CPU usage is high: 85.3%

### Errors
[2024-11-29 14:20:15] [ERROR] Failed to read GPU metrics
```

### Report Sections Explained

1. **Report Information**
   - Timestamp of generation
   - System identification
   - OS version

2. **System Overview**
   - Current metrics from all components
   - JSON-formatted data
   - Easy to parse programmatically

3. **Alerts and Warnings**
   - All warnings from the monitoring session
   - All errors encountered
   - Timestamps for each event

### Viewing Reports

#### Command Line
```bash
# View in terminal
cat reports/system_report_20241129_120000.md

# View with pagination
less reports/system_report_20241129_120000.md

# Convert to HTML (requires pandoc)
pandoc reports/system_report_20241129_120000.md -o report.html
```

#### Dashboard
1. Launch `./dashboard.sh`
2. Select option 9: "View Reports"
3. Choose report from list
4. View in built-in text viewer

#### Web Interface
1. Access `http://localhost:8080`
2. Use API: `/api/reports`
3. Download or view specific reports

---

## Working with Historical Data

### Data Files Location
All metrics are stored in CSV format in the `data/` directory:
- `cpu_metrics.csv`
- `memory_metrics.csv`
- `disk_metrics.csv`
- `gpu_metrics.csv`
- `network_metrics.csv`
- `system_metrics.csv`

### CSV Format

Each file contains comma-separated values:
```
timestamp,metric_type,value1,value2,value3,...
```

#### Example: CPU Metrics
```csv
20241129_120000,CPU,45.2,8,2.15 1.98 1.87,58.0
20241129_120100,CPU,47.8,8,2.20 2.00 1.90,59.5
```

### Analyzing Historical Data

#### Using Command Line Tools
```bash
# Count data points
wc -l data/cpu_metrics.csv

# View last 10 entries
tail -10 data/cpu_metrics.csv

# Find high CPU usage (>80%)
awk -F',' '$3 > 80 {print}' data/cpu_metrics.csv

# Calculate average CPU usage
awk -F',' '{sum+=$3; count++} END {print sum/count}' data/cpu_metrics.csv
```

#### Using Python
```python
import pandas as pd

# Load CPU data
df = pd.read_csv('data/cpu_metrics.csv', header=None)
df.columns = ['timestamp', 'type', 'usage', 'cores', 'load', 'temp']

# Calculate statistics
print(f"Average CPU: {df['usage'].mean():.2f}%")
print(f"Max CPU: {df['usage'].max():.2f}%")
print(f"Min CPU: {df['usage'].min():.2f}%")

# Plot data
df['usage'].plot()
```

#### Using Dashboard
1. Launch `./dashboard.sh`
2. Select option 11: "View Historical Data"
3. Choose metric type
4. View complete CSV file

---

## Alert System

### Alert Thresholds

Default thresholds (defined in `monitor.sh`):
- **CPU Usage**: 80%
- **Memory Usage**: 85%
- **Disk Usage**: 90%
- **CPU Temperature**: 75°C

### Alert Types

#### WARNING
- Threshold exceeded
- Non-critical issues
- Resource constraints

#### ERROR
- Command failures
- Missing dependencies
- Permission issues

### Alert Delivery

#### 1. Console Output
Alerts are displayed in color-coded format:
- 🔴 **Red**: Errors
- 🟡 **Yellow**: Warnings
- 🟢 **Green**: Info

#### 2. Log Files
All alerts are written to log files in `logs/`:
```
[2024-11-29 14:30:00] [WARNING] CPU usage is high: 85.3%
```

#### 3. Dashboard Display
The dashboard shows recent alerts in a dedicated section

#### 4. Web Interface
Alerts appear in the web dashboard's alert section

### Configuring Alerts

#### Method 1: Edit Script
Edit `monitor.sh` and change threshold values:
```bash
CPU_THRESHOLD=85        # Change from 80 to 85
MEMORY_THRESHOLD=90     # Change from 85 to 90
DISK_THRESHOLD=95       # Change from 90 to 95
```

#### Method 2: Use Dashboard
1. Launch `./dashboard.sh`
2. Select option 12: "Configure Thresholds"
3. Enter new values

---

## Best Practices

### 1. Regular Monitoring
```bash
# Run continuous monitoring
./monitor.sh continuous

# Or use Docker
docker-compose up -d monitor-collector
```

### 2. Periodic Reports
```bash
# Generate daily reports (use cron)
0 0 * * * cd /path/to/OSProject && ./monitor.sh report
```

### 3. Data Retention
```bash
# Clean old logs (keep last 30 days)
find logs/ -name "*.log" -mtime +30 -delete

# Archive old reports
tar -czf reports_archive_$(date +%Y%m).tar.gz reports/*.md
```

### 4. Disk Space Management
```bash
# Check data directory size
du -sh data/ logs/ reports/

# Compress large CSV files
gzip data/*.csv
```

### 5. Security
```bash
# Restrict permissions
chmod 700 monitor.sh dashboard.sh
chmod 600 logs/*.log

# Run with limited privileges (don't use sudo unless needed)
```

### 6. Performance Tuning
```bash
# Adjust monitoring interval in continuous mode
# Edit monitor.sh and change:
sleep 300  # Monitor every 5 minutes instead of 1
```

---

## FAQ

### General Questions

**Q: How often should I run monitoring?**  
A: For production systems, continuous monitoring (every 60 seconds) is recommended. For development, periodic checks are sufficient.

**Q: How much disk space do I need?**  
A: Approximately 1MB per day for logs and data. Plan for at least 1GB for a month of continuous monitoring.

**Q: Can I run this on Windows?**  
A: The bash scripts require Linux/Unix. Use Docker on Windows, or WSL (Windows Subsystem for Linux).

### Technical Questions

**Q: Why don't I see GPU metrics?**  
A: GPU monitoring requires nvidia-smi (NVIDIA) or radeontop (AMD). If not installed or no GPU present, it shows "N/A".

**Q: SMART status shows N/A, why?**  
A: SMART monitoring requires `smartmontools` and root/sudo privileges. Run: `sudo smartctl -H /dev/sda`

**Q: Temperature reading is unavailable?**  
A: Run `sudo sensors-detect` and answer YES to all prompts to detect sensors.

**Q: Can I monitor multiple servers?**  
A: Yes, deploy the Docker containers on each server and collect data centrally using the API endpoints.

### Docker Questions

**Q: How do I view data from Docker containers?**  
A: Data is persisted in mounted volumes. Check `./logs/`, `./data/`, and `./reports/` on the host.

**Q: Can I change the web interface port?**  
A: Yes, edit `docker-compose.yml` and change `ports: - "8080:8080"` to your desired port.

**Q: How do I update the monitoring script in a running container?**  
A: Edit the script on the host, then restart: `docker-compose restart monitor-collector`

### Troubleshooting

**Q: "Permission denied" error?**  
A: Make scripts executable: `chmod +x monitor.sh dashboard.sh`

**Q: "Command not found" for dialog?**  
A: Install dialog: `sudo apt-get install dialog`

**Q: No data appears in the dashboard?**  
A: Ensure monitoring has run at least once: `./monitor.sh monitor`

**Q: Web interface shows "Error loading metrics"?**  
A: Verify data files exist in `data/` and the server has read permissions.

---

## Support and Contact

For issues, questions, or suggestions:

**Teaching Assistants:**
- Eng. Youssef Ahmed Mehanna
- Eng. Ahmed Gamal

**Project Repository:**
- Check GitHub/GitLab for updates and issues

**Documentation:**
- `README.md` - Project overview
- `INSTALLATION.md` - Installation instructions
- `USER_MANUAL.md` - This document

---

## Appendix: Command Reference

### Quick Command Reference

```bash
# Monitoring Commands
./monitor.sh monitor          # Single scan
./monitor.sh continuous       # Continuous monitoring
./monitor.sh report          # Generate report
./monitor.sh cpu             # CPU only
./monitor.sh memory          # Memory only
./monitor.sh disk            # Disk only
./monitor.sh gpu             # GPU only
./monitor.sh network         # Network only
./monitor.sh system          # System load only

# Dashboard
./dashboard.sh               # Launch interactive GUI

# Docker Commands
docker-compose up -d monitor-collector     # Start monitoring
docker-compose run --rm monitor-reporter   # Generate report
docker-compose --profile web up -d         # Start web interface
docker-compose logs -f monitor-collector   # View logs
docker-compose down                        # Stop all services

# Data Management
ls -lh logs/                 # View logs
ls -lh reports/              # View reports
cat data/cpu_metrics.csv     # View CPU data
tail -f logs/monitor_*.log   # Follow log in real-time
```

---

**Project developed for Arab Academy for Science, Technology & Maritime Transport**  
**Operating Systems - Project 12**  
**Assistant Lecturers: Eng. Youssef Ahmed Mehanna & Eng. Ahmed Gamal**
