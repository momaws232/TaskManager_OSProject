# System Monitoring Solution

## Arab Academy for Science, Technology & Maritime Transport
### Operating Systems - Project 12

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)
![Docker](https://img.shields.io/badge/docker-ready-brightgreen.svg)

---

## 📋 Project Overview

A comprehensive system monitoring solution that collects, analyzes, and reports hardware and software performance metrics. Developed as part of the Operating Systems course at the Arab Academy for Science, Technology & Maritime Transport.

### 🎯 Project Objectives

- Develop advanced Bash scripting skills
- Learn Docker containerization
- Implement system monitoring techniques
- Create interactive GUI dashboards
- Apply Infrastructure as Code (IaC) concepts
- Generate professional reports and documentation

---

## ✨ Features

### Core Monitoring Capabilities
- ✅ **CPU Monitoring**: Performance, temperature, and load tracking
- ✅ **GPU Monitoring**: Utilization and health metrics (NVIDIA/AMD)
- ✅ **Disk Monitoring**: Usage and SMART status
- ✅ **Memory Monitoring**: RAM and swap consumption
- ✅ **Network Monitoring**: Interface statistics and transfer rates
- ✅ **System Load Monitoring**: Process counts and load averages

### Advanced Features
- 🔄 **Real-time Monitoring**: Continuous data collection
- 📊 **Historical Data Tracking**: Time-series data storage in CSV format
- 📈 **Interactive Dashboard**: Dialog/Whiptail-based GUI
- 🌐 **Web Interface**: Modern web-based visualization
- 📝 **Automated Reports**: Markdown and HTML report generation
- 🚨 **Alert System**: Configurable thresholds with notifications
- 🐳 **Docker Support**: Fully containerized deployment
- 📡 **REST API**: Programmatic access to metrics

---

## 🏗️ Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                     System Monitoring Solution               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   monitor.sh  │  │ dashboard.sh │  │  Web Server  │     │
│  │   (Bash)     │  │  (Dialog)    │  │  (Python)    │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │              │
│         └──────────────────┼──────────────────┘              │
│                            │                                 │
│                   ┌────────▼────────┐                       │
│                   │  Data Storage   │                       │
│                   │  - Logs         │                       │
│                   │  - Reports      │                       │
│                   │  - Metrics CSV  │                       │
│                   └─────────────────┘                       │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Docker Containers                        │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │  │
│  │  │  Collector  │  │  Reporter   │  │     Web     │ │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Collection**: Scripts gather metrics from system
2. **Storage**: Data saved to CSV files and logs
3. **Analysis**: Thresholds checked, alerts generated
4. **Reporting**: Reports created in multiple formats
5. **Visualization**: Data displayed via CLI, GUI, or web interface

---

## 🚀 Quick Start

### Prerequisites

- Linux operating system (Ubuntu 20.04+ recommended)
- Bash 4.0+
- Docker and Docker Compose (optional)
- Dialog/Whiptail for GUI
- Python 3.8+ (for web interface)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd OSProject

# Make scripts executable
chmod +x monitor.sh dashboard.sh

# Install dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y dialog bc sysstat net-tools lm-sensors

# Run your first monitoring cycle
./monitor.sh monitor
```

### Docker Quick Start

```bash
# Start continuous monitoring
docker-compose up -d monitor-collector

# View logs
docker-compose logs -f monitor-collector

# Generate a report
docker-compose run --rm monitor-reporter

# Start web interface
docker-compose --profile web up -d monitor-web
```

---

## 📖 Usage

### Command Line Interface

```bash
# Single monitoring cycle
./monitor.sh monitor

# Continuous monitoring (every 60 seconds)
./monitor.sh continuous

# Generate comprehensive report
./monitor.sh report

# Monitor specific components
./monitor.sh cpu        # CPU only
./monitor.sh memory     # Memory only
./monitor.sh disk       # Disk only
./monitor.sh gpu        # GPU only
./monitor.sh network    # Network only
./monitor.sh system     # System load only
```

### Interactive Dashboard

```bash
# Launch GUI dashboard
./dashboard.sh
```

**Dashboard Features:**
- View real-time metrics
- Generate reports
- View historical data
- Configure alert thresholds
- Start/stop continuous monitoring

### Real-Time GUI Application (NEW!)

```bash
# Windows - Double-click or run:
start-gui.bat

# Or with PowerShell:
.\start-gui.ps1

# Or direct Python:
python monitor_gui.py
```

**GUI Features:**
- 🖥️ Real-time dashboard with live updates (1-10 second intervals)
- 📊 6 metric cards: CPU, Memory, Disk, GPU, Network, System
- 🎨 Color-coded alerts and status indicators
- 📝 Activity log with warnings and errors
- ⏸️ Pause/Resume monitoring controls
- 🔄 Manual refresh and report generation
- ⚙️ Configurable update intervals

### Web Interface

```bash
# Start web server (Docker)
docker-compose --profile web up -d monitor-web

# Or start directly with Python
python3 web/server.py
```

Access at: `http://localhost:8080`

**Web Features:**
- Real-time dashboard with auto-refresh
- Historical data visualization
- Alert monitoring
- Report browsing
- REST API access

---

## 📊 Output Examples

### Console Output

```bash
$ ./monitor.sh cpu
{
  "timestamp": "20241129_143000",
  "cpu_usage": "45.2",
  "cpu_cores": "8",
  "load_average": "2.15, 1.98, 1.87",
  "temperature": "58.0"
}
```

### Report Sample

```markdown
# System Monitoring Report

## Report Information
- Generated: 2024-11-29 14:30:00
- Hostname: production-server
- OS: Linux 5.15.0-91-generic

## System Overview

### CPU Metrics
- Usage: 45.2%
- Cores: 8
- Load Average: 2.15, 1.98, 1.87
- Temperature: 58.0°C

### Alerts and Warnings
[2024-11-29 14:25:00] [WARNING] CPU usage is high: 85.3%
```

### Data Files (CSV)

```csv
20241129_120000,CPU,45.2,8,2.15 1.98 1.87,58.0
20241129_120100,CPU,47.8,8,2.20 2.00 1.90,59.5
20241129_120200,CPU,43.1,8,2.10 1.95 1.85,57.5
```

---

## 🐳 Docker Deployment

### Services

The project includes 4 Docker services:

1. **monitor-collector**: Continuous data collection
2. **monitor-reporter**: On-demand report generation
3. **monitor-dashboard**: Interactive CLI dashboard
4. **monitor-web**: Web visualization interface

### Docker Commands

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d monitor-collector

# View running containers
docker-compose ps

# View logs
docker-compose logs -f monitor-collector

# Stop services
docker-compose down

# Rebuild after changes
docker-compose build
docker-compose up -d --build
```

### Docker Compose Configuration

Key features:
- **Volume Mounting**: Persistent data storage
- **Resource Limits**: CPU and memory constraints
- **Health Checks**: Automatic service monitoring
- **Networking**: Isolated bridge network
- **Profiles**: Optional services (web, dashboard)

---

## 🔧 Configuration

### Alert Thresholds

Edit `monitor.sh` to customize alert thresholds:

```bash
# Default thresholds
CPU_THRESHOLD=80        # CPU usage %
MEMORY_THRESHOLD=85     # Memory usage %
DISK_THRESHOLD=90       # Disk usage %
TEMP_THRESHOLD=75       # Temperature °C
```

### Monitoring Interval

Change the sleep duration in continuous mode:

```bash
# In monitor.sh, find:
sleep 60  # Change to desired interval in seconds
```

### Data Retention

Configure automatic cleanup:

```bash
# Add to crontab
0 0 * * 0 find /path/to/OSProject/logs -mtime +30 -delete
```

---

## 📁 Project Structure

```
OSProject/
├── monitor.sh              # Main monitoring script (Bash)
├── dashboard.sh            # Interactive GUI dashboard (Dialog)
├── Dockerfile              # Docker image for monitoring
├── Dockerfile.web          # Docker image for web interface
├── docker-compose.yml      # Docker Compose configuration
├── requirements.txt        # Python dependencies
├── README.md              # Project overview (this file)
├── INSTALLATION.md        # Installation instructions
├── USER_MANUAL.md         # Detailed user guide
├── web/                   # Web interface files
│   ├── server.py          # Flask web server
│   └── templates/
│       └── index.html     # Dashboard HTML
├── logs/                  # Log files (auto-created)
├── reports/              # Generated reports (auto-created)
└── data/                 # Metrics CSV files (auto-created)
    ├── cpu_metrics.csv
    ├── memory_metrics.csv
    ├── disk_metrics.csv
    ├── gpu_metrics.csv
    ├── network_metrics.csv
    └── system_metrics.csv
```

---

## 🎓 Learning Outcomes

This project develops skills in:

### Technical Skills
- ✅ Advanced Bash scripting
- ✅ Docker containerization and orchestration
- ✅ System administration and monitoring
- ✅ GUI development with Dialog/Whiptail
- ✅ Web development with Flask
- ✅ REST API design
- ✅ Data visualization
- ✅ Infrastructure as Code (IaC)

### Professional Skills
- ✅ Teamwork and collaboration
- ✅ Problem-solving
- ✅ Technical documentation
- ✅ System design
- ✅ Performance analysis
- ✅ Project management

---

## 📚 Documentation

- **[INSTALLATION.md](INSTALLATION.md)**: Step-by-step installation guide
- **[USER_MANUAL.md](USER_MANUAL.md)**: Comprehensive user manual with examples
- **README.md**: This file - project overview

---

## 🎯 Grading Rubric

| Category | Points | Weight |
|----------|--------|--------|
| Bash Monitoring Script | 2 | 20% |
| Docker Containerization | 2 | 20% |
| Reporting System | 2 | 20% |
| Error Handling | 1 | 10% |
| Code Quality | 1 | 10% |
| Documentation | 1 | 10% |
| Project Presentation | 1 | 10% |
| **Total** | **10** | **100%** |

---

## 🔍 Key Features by Requirement

### ✅ Bash Monitoring Script (20%)
- Comprehensive metric collection
- Error handling and logging
- Modular function design
- Configurable thresholds
- Multiple output formats

### ✅ Docker Containerization (20%)
- Multi-service architecture
- Docker Compose orchestration
- Volume persistence
- Resource limits
- Health checks

### ✅ Reporting System (20%)
- Markdown report generation
- HTML web interface
- Historical data tracking
- Alert summaries
- API endpoints

### ✅ Error Handling (10%)
- Try-catch equivalents
- Graceful degradation
- Detailed error logging
- User-friendly messages
- Recovery mechanisms

### ✅ Code Quality (10%)
- Clean, readable code
- Consistent formatting
- Meaningful variable names
- Function modularity
- Comments and documentation

### ✅ Documentation (10%)
- README with overview
- Installation guide
- User manual
- Code comments
- API documentation

---

## 🛠️ Technologies Used

### Core Technologies
- **Bash**: Main scripting language
- **Docker**: Containerization platform
- **Docker Compose**: Multi-container orchestration
- **Dialog/Whiptail**: Terminal UI framework

### Web Stack
- **Python 3**: Web server language
- **Flask**: Web framework
- **HTML5/CSS3**: Frontend
- **JavaScript**: Interactive features

### Data Processing
- **CSV**: Data storage format
- **Markdown**: Report format
- **JSON**: API responses

### System Tools
- `top`, `free`, `df`: Resource monitoring
- `sensors`: Temperature monitoring
- `smartctl`: Disk health
- `ip`, `ifconfig`: Network stats

---

## 🚦 Getting Help

### Common Issues

See [INSTALLATION.md](INSTALLATION.md#troubleshooting) for detailed troubleshooting.

**Quick fixes:**
```bash
# Permission errors
chmod +x monitor.sh dashboard.sh

# Missing dependencies
sudo apt-get install dialog bc sysstat

# Docker permission issues
sudo usermod -aG docker $USER
# Then log out and back in
```

### Support Contacts

**Teaching Assistants:**
- Eng. Youssef Ahmed Mehanna
- Eng. Ahmed Gamal

**Resources:**
- Project documentation
- Course materials
- GitHub Issues (if applicable)

---

## 📅 Important Dates

- **Project Start**: Week 10
- **Discussion Deadline**: November 13th
- **Final Submission**: [Check with TA]
- **Presentation**: [Check with TA]

> ⚠️ **Important**: Project will be graded zero if discussion is not completed by November 13th.

---

## ⚖️ Academic Integrity

> **No plagiarism is allowed.** All work must be original and not derived from other teams or previously submitted projects.

This includes:
- ❌ Copying code from other teams
- ❌ Using previous year submissions
- ❌ Copying from online sources without attribution
- ✅ Using official documentation and tutorials (with proper attribution)
- ✅ Collaborating within your team
- ✅ Asking TAs for guidance

---

## 👥 Team Roles

Recommended team structure:

### Member 1: System Metrics Collection
- Develop monitoring scripts
- Implement data collection functions
- Create alert system

### Member 2: Docker Infrastructure
- Set up Dockerfile
- Configure docker-compose.yml
- Implement container orchestration

### Member 3: Dashboard Development
- Create interactive GUI
- Develop web interface
- Implement visualization features

> All members should contribute to documentation and testing.

---

## 🎬 Demo Script

For project presentation:

1. **Introduction** (2 min)
   - Project overview
   - Team member roles

2. **Live Demo** (8 min)
   - Run monitoring script
   - Show dashboard
   - Generate report
   - Display web interface
   - Demonstrate Docker deployment

3. **Code Walkthrough** (5 min)
   - Key functions
   - Error handling
   - Docker configuration

4. **Q&A** (5 min)
   - Answer questions
   - Discuss challenges
   - Show technical knowledge

---

## 📊 Sample Use Cases

### Use Case 1: Server Monitoring
```bash
# Start continuous monitoring on production server
./monitor.sh continuous &

# Check status periodically
./dashboard.sh

# Generate daily reports
0 0 * * * /path/to/monitor.sh report
```

### Use Case 2: Performance Analysis
```bash
# Collect data during load testing
./monitor.sh continuous &

# Run your application/tests
./run_tests.sh

# Analyze results
cat data/cpu_metrics.csv | awk -F',' '{sum+=$3} END {print sum/NR}'
```

### Use Case 3: Capacity Planning
```bash
# Monitor for 1 week
docker-compose up -d monitor-collector

# Generate weekly report
docker-compose run --rm monitor-reporter

# Analyze trends in data/ directory
```

---

## 🔮 Future Enhancements

Potential improvements:
- InfluxDB integration for time-series database
- Grafana dashboards for advanced visualization
- Email/SMS alert notifications
- Predictive analytics with ML
- Multi-server centralized monitoring
- Mobile app interface

---

## 📝 License

This project is developed for educational purposes at the Arab Academy for Science, Technology & Maritime Transport.

---

## 🙏 Acknowledgments

- **Course**: Operating Systems
- **Institution**: Arab Academy for Science, Technology & Maritime Transport
- **College**: College of Computing and Information Technology
- **Instructors**: Assistant Lecturers Eng. Youssef Ahmed Mehanna & Eng. Ahmed Gamal

---

## 📞 Contact

For questions, issues, or suggestions:

- **Project Team**: [Your Team Name]
- **Email**: [Your Team Email]
- **Teaching Assistants**:
  - Eng. Youssef Ahmed Mehanna
  - Eng. Ahmed Gamal

---

**Made with ❤️ for AASTMT OS Project 12**

*Last Updated: November 29, 2024*
