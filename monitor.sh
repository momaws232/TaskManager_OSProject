#!/bin/bash

################################################################################
# System Monitoring Script
# Arab Academy for Science, Technology & Maritime Transport
# Course: Operating Systems Project 12th
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOG_DIR="./logs"
REPORT_DIR="./reports"
DATA_DIR="./data"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/monitor_$TIMESTAMP.log"

# Thresholds for alerts
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90
TEMP_THRESHOLD=75

################################################################################
# Utility Functions
################################################################################

# Initialize directories
init_directories() {
    mkdir -p "$LOG_DIR" "$REPORT_DIR" "$DATA_DIR"
    log_message "INFO" "Directories initialized"
}

# Logging function
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Error handler
handle_error() {
    local error_message=$1
    log_message "ERROR" "$error_message"
    echo "Error: $error_message" >&2
}

################################################################################
# System Monitoring Functions
################################################################################

# Monitor CPU usage and temperature
monitor_cpu() {
    log_message "INFO" "Collecting CPU metrics..."
    
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    local cpu_cores=$(nproc)
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    
    # Try to get CPU temperature (may not work on all systems)
    local cpu_temp="N/A"
    if command -v sensors &> /dev/null; then
        cpu_temp=$(sensors 2>/dev/null | grep -i 'Core 0' | awk '{print $3}' | sed 's/+//;s/°C//' | head -n1)
    elif [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        cpu_temp=$(awk '{print $1/1000}' /sys/class/thermal/thermal_zone0/temp)
    fi
    
    # Save data
    echo "$TIMESTAMP,CPU,$cpu_usage,$cpu_cores,$load_avg,$cpu_temp" >> "$DATA_DIR/cpu_metrics.csv"
    
    # Check thresholds
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        log_message "WARNING" "CPU usage is high: ${cpu_usage}%"
    fi
    
    if [ "$cpu_temp" != "N/A" ] && (( $(echo "$cpu_temp > $TEMP_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        log_message "WARNING" "CPU temperature is high: ${cpu_temp}°C"
    fi
    
    # Return JSON-like format for easy parsing
    cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "cpu_usage": "$cpu_usage",
  "cpu_cores": "$cpu_cores",
  "load_average": "$load_avg",
  "temperature": "$cpu_temp"
}
EOF
}

# Monitor GPU utilization (if available)
monitor_gpu() {
    log_message "INFO" "Collecting GPU metrics..."
    
    local gpu_info="N/A"
    local gpu_usage="N/A"
    local gpu_memory="N/A"
    local gpu_temp="N/A"
    
    # Check for NVIDIA GPU
    if command -v nvidia-smi &> /dev/null; then
        gpu_info=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1)
        gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)
        gpu_memory=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -n1)
        gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)
    # Check for AMD GPU
    elif command -v radeontop &> /dev/null; then
        gpu_info="AMD GPU"
        gpu_usage=$(timeout 1s radeontop -d - -l 1 2>/dev/null | grep -oP 'gpu \K[0-9.]+' || echo "N/A")
    fi
    
    # Save data
    echo "$TIMESTAMP,GPU,$gpu_info,$gpu_usage,$gpu_memory,$gpu_temp" >> "$DATA_DIR/gpu_metrics.csv"
    
    cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "gpu_name": "$gpu_info",
  "gpu_usage": "$gpu_usage",
  "gpu_memory": "$gpu_memory",
  "gpu_temperature": "$gpu_temp"
}
EOF
}

# Monitor disk usage and SMART status
monitor_disk() {
    log_message "INFO" "Collecting disk metrics..."
    
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    local disk_total=$(df -h / | awk 'NR==2 {print $2}')
    local disk_used=$(df -h / | awk 'NR==2 {print $3}')
    local disk_available=$(df -h / | awk 'NR==2 {print $4}')
    
    # Get all mounted filesystems
    local all_disks=$(df -h | awk 'NR>1 {printf "%s (%s/%s used, %s%% full)\\n", $6, $3, $2, $5}')
    
    # Try to get SMART status
    local smart_status="N/A"
    if command -v smartctl &> /dev/null; then
        local disk_device=$(df / | awk 'NR==2 {print $1}' | sed 's/[0-9]*$//')
        smart_status=$(sudo smartctl -H "$disk_device" 2>/dev/null | grep -i "SMART overall-health" | awk '{print $NF}' || echo "N/A")
    fi
    
    # Save data
    echo "$TIMESTAMP,DISK,$disk_usage,$disk_total,$disk_used,$disk_available,$smart_status" >> "$DATA_DIR/disk_metrics.csv"
    
    # Check threshold
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ] 2>/dev/null; then
        log_message "WARNING" "Disk usage is high: ${disk_usage}%"
    fi
    
    cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "disk_usage_percent": "$disk_usage",
  "disk_total": "$disk_total",
  "disk_used": "$disk_used",
  "disk_available": "$disk_available",
  "smart_status": "$smart_status",
  "all_disks": "$all_disks"
}
EOF
}

# Monitor memory consumption
monitor_memory() {
    log_message "INFO" "Collecting memory metrics..."
    
    local mem_total=$(free -m | awk 'NR==2 {print $2}')
    local mem_used=$(free -m | awk 'NR==2 {print $3}')
    local mem_free=$(free -m | awk 'NR==2 {print $4}')
    local mem_available=$(free -m | awk 'NR==2 {print $7}')
    local mem_percent=$(awk "BEGIN {printf \"%.2f\", ($mem_used/$mem_total)*100}")
    
    local swap_total=$(free -m | awk 'NR==3 {print $2}')
    local swap_used=$(free -m | awk 'NR==3 {print $3}')
    local swap_free=$(free -m | awk 'NR==3 {print $4}')
    
    # Save data
    echo "$TIMESTAMP,MEMORY,$mem_total,$mem_used,$mem_free,$mem_available,$mem_percent,$swap_total,$swap_used" >> "$DATA_DIR/memory_metrics.csv"
    
    # Check threshold
    if (( $(echo "$mem_percent > $MEMORY_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        log_message "WARNING" "Memory usage is high: ${mem_percent}%"
    fi
    
    cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "memory_total_mb": "$mem_total",
  "memory_used_mb": "$mem_used",
  "memory_free_mb": "$mem_free",
  "memory_available_mb": "$mem_available",
  "memory_percent": "$mem_percent",
  "swap_total_mb": "$swap_total",
  "swap_used_mb": "$swap_used",
  "swap_free_mb": "$swap_free"
}
EOF
}

# Monitor network interface statistics
monitor_network() {
    log_message "INFO" "Collecting network metrics..."
    
    local primary_interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    
    if [ -z "$primary_interface" ]; then
        primary_interface="eth0"
    fi
    
    # Get network statistics
    local rx_bytes=$(cat "/sys/class/net/$primary_interface/statistics/rx_bytes" 2>/dev/null || echo "0")
    local tx_bytes=$(cat "/sys/class/net/$primary_interface/statistics/tx_bytes" 2>/dev/null || echo "0")
    local rx_packets=$(cat "/sys/class/net/$primary_interface/statistics/rx_packets" 2>/dev/null || echo "0")
    local tx_packets=$(cat "/sys/class/net/$primary_interface/statistics/tx_packets" 2>/dev/null || echo "0")
    
    # Convert to human-readable format
    local rx_mb=$(awk "BEGIN {printf \"%.2f\", $rx_bytes/1024/1024}")
    local tx_mb=$(awk "BEGIN {printf \"%.2f\", $tx_bytes/1024/1024}")
    
    # Get IP address
    local ip_address=$(ip addr show "$primary_interface" 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1 || echo "N/A")
    
    # Get connection status
    local connection_status=$(cat "/sys/class/net/$primary_interface/operstate" 2>/dev/null || echo "unknown")
    
    # Save data
    echo "$TIMESTAMP,NETWORK,$primary_interface,$rx_mb,$tx_mb,$rx_packets,$tx_packets,$ip_address,$connection_status" >> "$DATA_DIR/network_metrics.csv"
    
    cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "interface": "$primary_interface",
  "rx_mb": "$rx_mb",
  "tx_mb": "$tx_mb",
  "rx_packets": "$rx_packets",
  "tx_packets": "$tx_packets",
  "ip_address": "$ip_address",
  "status": "$connection_status"
}
EOF
}

# Monitor system load metrics
monitor_system_load() {
    log_message "INFO" "Collecting system load metrics..."
    
    local uptime_info=$(uptime -p)
    local load_1min=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
    local load_5min=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $2}' | xargs)
    local load_15min=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $3}' | xargs)
    
    local total_processes=$(ps aux | wc -l)
    local running_processes=$(ps aux | grep -c " R ")
    local zombie_processes=$(ps aux | grep -c " Z ")
    
    local logged_users=$(who | wc -l)
    
    # Save data
    echo "$TIMESTAMP,SYSTEM,$load_1min,$load_5min,$load_15min,$total_processes,$running_processes,$zombie_processes,$logged_users" >> "$DATA_DIR/system_metrics.csv"
    
    cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "uptime": "$uptime_info",
  "load_1min": "$load_1min",
  "load_5min": "$load_5min",
  "load_15min": "$load_15min",
  "total_processes": "$total_processes",
  "running_processes": "$running_processes",
  "zombie_processes": "$zombie_processes",
  "logged_users": "$logged_users"
}
EOF
}

################################################################################
# Report Generation
################################################################################

# Generate comprehensive report
generate_report() {
    log_message "INFO" "Generating comprehensive report..."
    
    local report_file="$REPORT_DIR/system_report_$TIMESTAMP.md"
    
    cat > "$report_file" <<'REPORT_HEADER'
# System Monitoring Report

---

## Report Information
REPORT_HEADER

    echo "- **Generated**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$report_file"
    echo "- **Hostname**: $(hostname)" >> "$report_file"
    echo "- **OS**: $(uname -s) $(uname -r)" >> "$report_file"
    echo "" >> "$report_file"
    
    echo "## System Overview" >> "$report_file"
    echo "" >> "$report_file"
    
    # CPU Section
    echo "### CPU Metrics" >> "$report_file"
    local cpu_data=$(monitor_cpu)
    echo '```' >> "$report_file"
    echo "$cpu_data" >> "$report_file"
    echo '```' >> "$report_file"
    echo "" >> "$report_file"
    
    # Memory Section
    echo "### Memory Metrics" >> "$report_file"
    local mem_data=$(monitor_memory)
    echo '```' >> "$report_file"
    echo "$mem_data" >> "$report_file"
    echo '```' >> "$report_file"
    echo "" >> "$report_file"
    
    # Disk Section
    echo "### Disk Metrics" >> "$report_file"
    local disk_data=$(monitor_disk)
    echo '```' >> "$report_file"
    echo "$disk_data" >> "$report_file"
    echo '```' >> "$report_file"
    echo "" >> "$report_file"
    
    # GPU Section
    echo "### GPU Metrics" >> "$report_file"
    local gpu_data=$(monitor_gpu)
    echo '```' >> "$report_file"
    echo "$gpu_data" >> "$report_file"
    echo '```' >> "$report_file"
    echo "" >> "$report_file"
    
    # Network Section
    echo "### Network Metrics" >> "$report_file"
    local net_data=$(monitor_network)
    echo '```' >> "$report_file"
    echo "$net_data" >> "$report_file"
    echo '```' >> "$report_file"
    echo "" >> "$report_file"
    
    # System Load Section
    echo "### System Load Metrics" >> "$report_file"
    local load_data=$(monitor_system_load)
    echo '```' >> "$report_file"
    echo "$load_data" >> "$report_file"
    echo '```' >> "$report_file"
    echo "" >> "$report_file"
    
    # Alerts Section
    echo "## Alerts and Warnings" >> "$report_file"
    echo "" >> "$report_file"
    if [ -f "$LOG_FILE" ]; then
        local warnings=$(grep "WARNING" "$LOG_FILE" 2>/dev/null)
        local errors=$(grep "ERROR" "$LOG_FILE" 2>/dev/null)
        
        if [ -n "$warnings" ] || [ -n "$errors" ]; then
            echo "### Warnings" >> "$report_file"
            echo '```' >> "$report_file"
            echo "$warnings" >> "$report_file"
            echo '```' >> "$report_file"
            echo "" >> "$report_file"
            
            echo "### Errors" >> "$report_file"
            echo '```' >> "$report_file"
            echo "$errors" >> "$report_file"
            echo '```' >> "$report_file"
        else
            echo "No warnings or errors detected." >> "$report_file"
        fi
    fi
    
    echo "" >> "$report_file"
    echo "---" >> "$report_file"
    echo "*Report generated by System Monitor v1.0*" >> "$report_file"
    
    log_message "INFO" "Report generated: $report_file"
    echo "$report_file"
}

################################################################################
# Main Execution
################################################################################

# Main function
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  System Monitoring Tool${NC}"
    echo -e "${BLUE}  AASTMT - OS Project 12${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    init_directories
    
    case "${1:-monitor}" in
        monitor)
            echo "Running full system monitoring..."
            monitor_cpu > /dev/null
            monitor_memory > /dev/null
            monitor_disk > /dev/null
            monitor_gpu > /dev/null
            monitor_network > /dev/null
            monitor_system_load > /dev/null
            echo -e "${GREEN}Monitoring complete!${NC}"
            ;;
        report)
            echo "Generating comprehensive report..."
            report_file=$(generate_report)
            echo -e "${GREEN}Report generated: $report_file${NC}"
            ;;
        continuous)
            echo "Starting continuous monitoring (Ctrl+C to stop)..."
            while true; do
                monitor_cpu > /dev/null
                monitor_memory > /dev/null
                monitor_disk > /dev/null
                monitor_gpu > /dev/null
                monitor_network > /dev/null
                monitor_system_load > /dev/null
                echo -e "${GREEN}[$(date '+%H:%M:%S')] Monitoring cycle complete${NC}"
                sleep 60
            done
            ;;
        cpu)
            monitor_cpu
            ;;
        memory)
            monitor_memory
            ;;
        disk)
            monitor_disk
            ;;
        gpu)
            monitor_gpu
            ;;
        network)
            monitor_network
            ;;
        system)
            monitor_system_load
            ;;
        *)
            echo "Usage: $0 {monitor|report|continuous|cpu|memory|disk|gpu|network|system}"
            echo ""
            echo "Commands:"
            echo "  monitor     - Run single monitoring cycle for all components"
            echo "  report      - Generate comprehensive markdown report"
            echo "  continuous  - Run continuous monitoring (every 60 seconds)"
            echo "  cpu         - Monitor CPU only"
            echo "  memory      - Monitor memory only"
            echo "  disk        - Monitor disk only"
            echo "  gpu         - Monitor GPU only"
            echo "  network     - Monitor network only"
            echo "  system      - Monitor system load only"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
