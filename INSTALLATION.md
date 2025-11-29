# System Monitoring Solution - Installation Guide

## Arab Academy for Science, Technology & Maritime Transport
### Operating Systems - Project 12

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Docker Deployment](#docker-deployment)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements
- **Operating System**: Linux (Ubuntu 20.04+, Debian, CentOS, or similar)
- **RAM**: Minimum 512MB
- **Disk Space**: Minimum 1GB free space
- **Processor**: Any modern CPU

### Required Software

#### For Bash Scripts (Non-Docker)
```bash
# Update package list
sudo apt-get update

# Install required packages
sudo apt-get install -y \
    bash \
    coreutils \
    procps \
    sysstat \
    net-tools \
    iproute2 \
    dialog \
    bc \
    lm-sensors \
    smartmontools
```

#### For Docker Deployment
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

#### For Web Interface (Optional)
```bash
# Install Python 3 and pip
sudo apt-get install -y python3 python3-pip

# Install Python dependencies
pip3 install -r requirements.txt
```

---

## Installation

### Method 1: Clone from Repository
```bash
# Clone the repository
git clone <your-repository-url>
cd OSProject

# Make scripts executable
chmod +x monitor.sh dashboard.sh
```

### Method 2: Manual Setup
```bash
# Create project directory
mkdir -p OSProject
cd OSProject

# Copy all project files to this directory
# (monitor.sh, dashboard.sh, Dockerfile, docker-compose.yml, etc.)

# Make scripts executable
chmod +x monitor.sh dashboard.sh
```

### Directory Structure
After installation, your directory should look like this:
```
OSProject/
├── monitor.sh              # Main monitoring script
├── dashboard.sh            # Interactive dashboard
├── Dockerfile              # Docker image for monitoring
├── Dockerfile.web          # Docker image for web interface
├── docker-compose.yml      # Docker Compose configuration
├── requirements.txt        # Python dependencies
├── README.md              # This file
├── INSTALLATION.md        # Installation guide
├── USER_MANUAL.md         # User manual
├── web/                   # Web interface files
│   ├── server.py
│   └── templates/
│       └── index.html
├── logs/                  # Log files (auto-created)
├── reports/              # Generated reports (auto-created)
└── data/                 # Metrics data (auto-created)
```

---

## Usage

### Running Bash Scripts Directly

#### 1. Single Monitoring Cycle
Collect metrics once from all components:
```bash
./monitor.sh monitor
```

#### 2. Generate Report
Create a comprehensive markdown report:
```bash
./monitor.sh report
```

#### 3. Continuous Monitoring
Run monitoring in a loop (every 60 seconds):
```bash
./monitor.sh continuous
```
Press `Ctrl+C` to stop.

#### 4. Monitor Specific Component
```bash
# CPU only
./monitor.sh cpu

# Memory only
./monitor.sh memory

# Disk only
./monitor.sh disk

# GPU only
./monitor.sh gpu

# Network only
./monitor.sh network

# System load only
./monitor.sh system
```

#### 5. Interactive Dashboard
Launch the GUI dashboard:
```bash
./dashboard.sh
```

---

## Docker Deployment

### Quick Start with Docker Compose

#### 1. Start Data Collection Service
Runs continuous monitoring in the background:
```bash
docker-compose up -d monitor-collector
```

#### 2. Generate a Report
```bash
docker-compose run --rm monitor-reporter
```

#### 3. Launch Interactive Dashboard
```bash
docker-compose run --rm monitor-dashboard
```

#### 4. Start Web Interface
Launch the web visualization interface:
```bash
docker-compose --profile web up -d monitor-web
```
Access the web interface at: `http://localhost:8080`

### Docker Commands

#### View Running Containers
```bash
docker-compose ps
```

#### View Logs
```bash
# View collector logs
docker-compose logs -f monitor-collector

# View web server logs
docker-compose logs -f monitor-web
```

#### Stop Services
```bash
# Stop all services
docker-compose down

# Stop specific service
docker-compose stop monitor-collector
```

#### Restart Services
```bash
docker-compose restart monitor-collector
```

#### Remove All Containers and Volumes
```bash
docker-compose down -v
```

### Building Docker Images

If you modify the scripts or Dockerfile:
```bash
# Rebuild images
docker-compose build

# Rebuild and start
docker-compose up -d --build
```

---

## Configuration

### Modifying Alert Thresholds

Edit `monitor.sh` and change these values:
```bash
CPU_THRESHOLD=80        # CPU usage percentage
MEMORY_THRESHOLD=85     # Memory usage percentage
DISK_THRESHOLD=90       # Disk usage percentage
TEMP_THRESHOLD=75       # CPU temperature in Celsius
```

### Changing Monitoring Interval

For continuous monitoring, edit the sleep duration in `monitor.sh`:
```bash
# Change from 60 seconds to your desired interval
sleep 60
```

For Docker deployment, you can modify the monitoring script or create a custom configuration.

---

## Testing the Installation

### 1. Test Bash Script
```bash
# Run a quick test
./monitor.sh cpu

# Expected output: JSON with CPU metrics
```

### 2. Test Dashboard
```bash
# Launch dashboard
./dashboard.sh

# You should see a menu interface
```

### 3. Test Docker
```bash
# Build and test
docker-compose up monitor-collector

# Check if data is being collected
ls -la data/
ls -la logs/
```

### 4. Test Web Interface
```bash
# Start web service
docker-compose --profile web up monitor-web

# Visit http://localhost:8080 in your browser
```

---

## File Permissions

Ensure proper permissions for all scripts:
```bash
# Make scripts executable
chmod +x monitor.sh dashboard.sh

# Set directory permissions
chmod 755 logs/ reports/ data/
```

---

## Network Configuration

### Opening Firewall Ports (if needed)

For the web interface:
```bash
# Ubuntu/Debian with UFW
sudo ufw allow 8080/tcp

# CentOS/RHEL with firewalld
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

---

## Troubleshooting

### Common Issues

#### 1. Permission Denied
```bash
# Error: Permission denied
# Solution:
chmod +x monitor.sh dashboard.sh
```

#### 2. Command Not Found
```bash
# Error: dialog: command not found
# Solution:
sudo apt-get install dialog
```

#### 3. Docker Permission Issues
```bash
# Error: permission denied while trying to connect to Docker
# Solution:
sudo usermod -aG docker $USER
# Then log out and log back in
```

#### 4. Sensors Not Working
```bash
# Error: No sensors found
# Solution:
sudo sensors-detect
# Answer YES to all questions
sudo service kmod start
```

#### 5. Port Already in Use
```bash
# Error: Port 8080 already in use
# Solution: Change port in docker-compose.yml
ports:
  - "8081:8080"  # Use 8081 instead
```

### Viewing Detailed Logs

Check log files for errors:
```bash
# View latest log
cat logs/monitor_*.log | tail -50

# Search for errors
grep "ERROR" logs/*.log

# Search for warnings
grep "WARNING" logs/*.log
```

### Getting Help

For additional support:
1. Check the USER_MANUAL.md for detailed usage instructions
2. Review log files in the `logs/` directory
3. Contact your teaching assistants:
   - Eng. Youssef Ahmed Mehanna
   - Eng. Ahmed Gamal

---

## Next Steps

After successful installation:
1. Read the [User Manual](USER_MANUAL.md) for detailed usage instructions
2. Run a full system scan: `./monitor.sh monitor`
3. Generate your first report: `./monitor.sh report`
4. Explore the interactive dashboard: `./dashboard.sh`
5. Try the web interface: `docker-compose --profile web up -d monitor-web`

---

## Uninstallation

To remove the system:

### Remove Docker Containers
```bash
docker-compose down -v
docker rmi $(docker images -q 'osproject*')
```

### Remove Files
```bash
cd ..
rm -rf OSProject/
```

### Remove Installed Packages (Optional)
```bash
sudo apt-get remove dialog whiptail
```

---

**Project developed for Arab Academy for Science, Technology & Maritime Transport**  
**Operating Systems - Project 12**  
**Assistant Lecturers: Eng. Youssef Ahmed Mehanna & Eng. Ahmed Gamal**
