#!/bin/bash

################################################################################
# Interactive System Monitoring Dashboard
# Uses dialog/whiptail for GUI
# Arab Academy for Science, Technology & Maritime Transport
################################################################################

# Detect which dialog tool is available
if command -v dialog &> /dev/null; then
    DIALOG="dialog"
elif command -v whiptail &> /dev/null; then
    DIALOG="whiptail"
else
    echo "Error: Neither dialog nor whiptail is installed."
    echo "Please install one of them: sudo apt-get install dialog"
    exit 1
fi

# Configuration
MONITOR_SCRIPT="./monitor.sh"
TEMP_FILE="/tmp/dashboard_$$"
LOG_DIR="./logs"
REPORT_DIR="./reports"
DATA_DIR="./data"

# Cleanup on exit
trap "rm -f $TEMP_FILE" EXIT

################################################################################
# Dialog Helper Functions
################################################################################

show_message() {
    local title="$1"
    local message="$2"
    $DIALOG --title "$title" --msgbox "$message" 20 70
}

show_info() {
    local title="$1"
    local message="$2"
    $DIALOG --title "$title" --infobox "$message" 10 60
    sleep 2
}

show_error() {
    local message="$1"
    $DIALOG --title "Error" --msgbox "$message" 10 60
}

################################################################################
# Monitoring Display Functions
################################################################################

display_cpu_info() {
    show_info "CPU Monitoring" "Collecting CPU metrics..."
    
    if [ -f "$MONITOR_SCRIPT" ]; then
        local cpu_data=$(bash "$MONITOR_SCRIPT" cpu)
        show_message "CPU Metrics" "$cpu_data"
    else
        show_error "Monitor script not found: $MONITOR_SCRIPT"
    fi
}

display_memory_info() {
    show_info "Memory Monitoring" "Collecting memory metrics..."
    
    if [ -f "$MONITOR_SCRIPT" ]; then
        local mem_data=$(bash "$MONITOR_SCRIPT" memory)
        show_message "Memory Metrics" "$mem_data"
    else
        show_error "Monitor script not found: $MONITOR_SCRIPT"
    fi
}

display_disk_info() {
    show_info "Disk Monitoring" "Collecting disk metrics..."
    
    if [ -f "$MONITOR_SCRIPT" ]; then
        local disk_data=$(bash "$MONITOR_SCRIPT" disk)
        show_message "Disk Metrics" "$disk_data"
    else
        show_error "Monitor script not found: $MONITOR_SCRIPT"
    fi
}

display_gpu_info() {
    show_info "GPU Monitoring" "Collecting GPU metrics..."
    
    if [ -f "$MONITOR_SCRIPT" ]; then
        local gpu_data=$(bash "$MONITOR_SCRIPT" gpu)
        show_message "GPU Metrics" "$gpu_data"
    else
        show_error "Monitor script not found: $MONITOR_SCRIPT"
    fi
}

display_network_info() {
    show_info "Network Monitoring" "Collecting network metrics..."
    
    if [ -f "$MONITOR_SCRIPT" ]; then
        local net_data=$(bash "$MONITOR_SCRIPT" network)
        show_message "Network Metrics" "$net_data"
    else
        show_error "Monitor script not found: $MONITOR_SCRIPT"
    fi
}

display_system_info() {
    show_info "System Load Monitoring" "Collecting system metrics..."
    
    if [ -f "$MONITOR_SCRIPT" ]; then
        local sys_data=$(bash "$MONITOR_SCRIPT" system)
        show_message "System Load Metrics" "$sys_data"
    else
        show_error "Monitor script not found: $MONITOR_SCRIPT"
    fi
}

display_all_metrics() {
    show_info "Full System Scan" "Collecting all system metrics..."
    
    if [ -f "$MONITOR_SCRIPT" ]; then
        bash "$MONITOR_SCRIPT" monitor
        
        # Display summary
        local summary="System Monitoring Complete!\n\n"
        summary+="Data collected for:\n"
        summary+="- CPU Performance\n"
        summary+="- Memory Usage\n"
        summary+="- Disk Usage\n"
        summary+="- GPU Status\n"
        summary+="- Network Statistics\n"
        summary+="- System Load\n\n"
        summary+="Check the logs directory for details."
        
        show_message "Monitoring Complete" "$summary"
    else
        show_error "Monitor script not found: $MONITOR_SCRIPT"
    fi
}

################################################################################
# Report Functions
################################################################################

generate_report() {
    show_info "Report Generation" "Generating comprehensive report..."
    
    if [ -f "$MONITOR_SCRIPT" ]; then
        local report_path=$(bash "$MONITOR_SCRIPT" report)
        
        if [ -f "$report_path" ]; then
            show_message "Report Generated" "Report successfully generated:\n\n$report_path\n\nYou can view it with any markdown viewer."
        else
            show_error "Failed to generate report"
        fi
    else
        show_error "Monitor script not found: $MONITOR_SCRIPT"
    fi
}

view_reports() {
    if [ ! -d "$REPORT_DIR" ] || [ -z "$(ls -A $REPORT_DIR 2>/dev/null)" ]; then
        show_message "No Reports" "No reports have been generated yet.\n\nUse 'Generate Report' to create one."
        return
    fi
    
    local report_list=()
    local counter=1
    
    while IFS= read -r report; do
        report_list+=("$counter" "$(basename "$report")")
        ((counter++))
    done < <(ls -t "$REPORT_DIR"/*.md 2>/dev/null)
    
    if [ ${#report_list[@]} -eq 0 ]; then
        show_message "No Reports" "No reports found."
        return
    fi
    
    local choice=$($DIALOG --title "Available Reports" --menu "Select a report to view:" 20 70 10 "${report_list[@]}" 3>&1 1>&2 2>&3)
    
    if [ -n "$choice" ]; then
        local selected_report=$(ls -t "$REPORT_DIR"/*.md 2>/dev/null | sed -n "${choice}p")
        if [ -f "$selected_report" ]; then
            $DIALOG --title "Report: $(basename "$selected_report")" --textbox "$selected_report" 30 100
        fi
    fi
}

view_logs() {
    if [ ! -d "$LOG_DIR" ] || [ -z "$(ls -A $LOG_DIR 2>/dev/null)" ]; then
        show_message "No Logs" "No log files found."
        return
    fi
    
    local log_list=()
    local counter=1
    
    while IFS= read -r log; do
        log_list+=("$counter" "$(basename "$log")")
        ((counter++))
    done < <(ls -t "$LOG_DIR"/*.log 2>/dev/null)
    
    if [ ${#log_list[@]} -eq 0 ]; then
        show_message "No Logs" "No log files found."
        return
    fi
    
    local choice=$($DIALOG --title "Available Logs" --menu "Select a log to view:" 20 70 10 "${log_list[@]}" 3>&1 1>&2 2>&3)
    
    if [ -n "$choice" ]; then
        local selected_log=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | sed -n "${choice}p")
        if [ -f "$selected_log" ]; then
            $DIALOG --title "Log: $(basename "$selected_log")" --textbox "$selected_log" 30 100
        fi
    fi
}

################################################################################
# Data Analysis Functions
################################################################################

view_historical_data() {
    if [ ! -d "$DATA_DIR" ] || [ -z "$(ls -A $DATA_DIR 2>/dev/null)" ]; then
        show_message "No Data" "No historical data available yet.\n\nRun monitoring to collect data."
        return
    fi
    
    local data_list=()
    data_list+=("1" "CPU Metrics")
    data_list+=("2" "Memory Metrics")
    data_list+=("3" "Disk Metrics")
    data_list+=("4" "GPU Metrics")
    data_list+=("5" "Network Metrics")
    data_list+=("6" "System Metrics")
    
    local choice=$($DIALOG --title "Historical Data" --menu "Select data type to view:" 20 70 10 "${data_list[@]}" 3>&1 1>&2 2>&3)
    
    case $choice in
        1)
            if [ -f "$DATA_DIR/cpu_metrics.csv" ]; then
                $DIALOG --title "CPU Historical Data" --textbox "$DATA_DIR/cpu_metrics.csv" 30 100
            else
                show_message "No Data" "No CPU data available."
            fi
            ;;
        2)
            if [ -f "$DATA_DIR/memory_metrics.csv" ]; then
                $DIALOG --title "Memory Historical Data" --textbox "$DATA_DIR/memory_metrics.csv" 30 100
            else
                show_message "No Data" "No memory data available."
            fi
            ;;
        3)
            if [ -f "$DATA_DIR/disk_metrics.csv" ]; then
                $DIALOG --title "Disk Historical Data" --textbox "$DATA_DIR/disk_metrics.csv" 30 100
            else
                show_message "No Data" "No disk data available."
            fi
            ;;
        4)
            if [ -f "$DATA_DIR/gpu_metrics.csv" ]; then
                $DIALOG --title "GPU Historical Data" --textbox "$DATA_DIR/gpu_metrics.csv" 30 100
            else
                show_message "No Data" "No GPU data available."
            fi
            ;;
        5)
            if [ -f "$DATA_DIR/network_metrics.csv" ]; then
                $DIALOG --title "Network Historical Data" --textbox "$DATA_DIR/network_metrics.csv" 30 100
            else
                show_message "No Data" "No network data available."
            fi
            ;;
        6)
            if [ -f "$DATA_DIR/system_metrics.csv" ]; then
                $DIALOG --title "System Historical Data" --textbox "$DATA_DIR/system_metrics.csv" 30 100
            else
                show_message "No Data" "No system data available."
            fi
            ;;
    esac
}

################################################################################
# Settings and Configuration
################################################################################

configure_thresholds() {
    local cpu_thresh=$($DIALOG --title "CPU Threshold" --inputbox "Enter CPU usage threshold (%):" 10 60 "80" 3>&1 1>&2 2>&3)
    local mem_thresh=$($DIALOG --title "Memory Threshold" --inputbox "Enter memory usage threshold (%):" 10 60 "85" 3>&1 1>&2 2>&3)
    local disk_thresh=$($DIALOG --title "Disk Threshold" --inputbox "Enter disk usage threshold (%):" 10 60 "90" 3>&1 1>&2 2>&3)
    
    if [ -n "$cpu_thresh" ] && [ -n "$mem_thresh" ] && [ -n "$disk_thresh" ]; then
        # Update thresholds in monitor script
        show_message "Thresholds Updated" "New thresholds:\n\nCPU: ${cpu_thresh}%\nMemory: ${mem_thresh}%\nDisk: ${disk_thresh}%\n\nNote: To make these permanent, edit monitor.sh"
    fi
}

start_continuous_monitoring() {
    $DIALOG --title "Continuous Monitoring" --yesno "Start continuous monitoring in background?\n\nThis will monitor the system every 60 seconds.\nYou can stop it from the main menu." 12 60
    
    if [ $? -eq 0 ]; then
        if [ -f "$MONITOR_SCRIPT" ]; then
            nohup bash "$MONITOR_SCRIPT" continuous > /tmp/monitor_continuous.log 2>&1 &
            echo $! > /tmp/monitor_continuous.pid
            show_message "Started" "Continuous monitoring started in background.\n\nPID: $!\n\nLogs: /tmp/monitor_continuous.log"
        else
            show_error "Monitor script not found: $MONITOR_SCRIPT"
        fi
    fi
}

stop_continuous_monitoring() {
    if [ -f /tmp/monitor_continuous.pid ]; then
        local pid=$(cat /tmp/monitor_continuous.pid)
        if ps -p $pid > /dev/null 2>&1; then
            kill $pid
            rm -f /tmp/monitor_continuous.pid
            show_message "Stopped" "Continuous monitoring stopped.\n\nPID: $pid"
        else
            show_message "Not Running" "Continuous monitoring is not running."
            rm -f /tmp/monitor_continuous.pid
        fi
    else
        show_message "Not Running" "Continuous monitoring is not running."
    fi
}

################################################################################
# Main Menu
################################################################################

show_main_menu() {
    while true; do
        local choice=$($DIALOG --title "System Monitoring Dashboard - AASTMT OS Project" \
            --menu "Select an option:" 25 80 17 \
            "1" "View CPU Metrics" \
            "2" "View Memory Metrics" \
            "3" "View Disk Metrics" \
            "4" "View GPU Metrics" \
            "5" "View Network Metrics" \
            "6" "View System Load Metrics" \
            "7" "Run Full System Scan" \
            "8" "Generate Report" \
            "9" "View Reports" \
            "10" "View Logs" \
            "11" "View Historical Data" \
            "12" "Configure Thresholds" \
            "13" "Start Continuous Monitoring" \
            "14" "Stop Continuous Monitoring" \
            "15" "About" \
            "16" "Exit" \
            3>&1 1>&2 2>&3)
        
        case $choice in
            1) display_cpu_info ;;
            2) display_memory_info ;;
            3) display_disk_info ;;
            4) display_gpu_info ;;
            5) display_network_info ;;
            6) display_system_info ;;
            7) display_all_metrics ;;
            8) generate_report ;;
            9) view_reports ;;
            10) view_logs ;;
            11) view_historical_data ;;
            12) configure_thresholds ;;
            13) start_continuous_monitoring ;;
            14) stop_continuous_monitoring ;;
            15)
                show_message "About" "System Monitoring Dashboard v1.0\n\nDeveloped for:\nArab Academy for Science, Technology & Maritime Transport\nOperating Systems - Project 12\n\nFeatures:\n- Real-time system monitoring\n- Historical data tracking\n- Report generation\n- Alert system\n- Docker containerization support"
                ;;
            16|"")
                $DIALOG --title "Exit" --yesno "Are you sure you want to exit?" 7 40
                if [ $? -eq 0 ]; then
                    clear
                    echo "Thank you for using System Monitoring Dashboard!"
                    exit 0
                fi
                ;;
        esac
    done
}

################################################################################
# Entry Point
################################################################################

# Check if monitor script exists
if [ ! -f "$MONITOR_SCRIPT" ]; then
    show_error "Monitor script not found: $MONITOR_SCRIPT\n\nPlease ensure monitor.sh is in the same directory."
    exit 1
fi

# Make monitor script executable
chmod +x "$MONITOR_SCRIPT" 2>/dev/null

# Start the dashboard
clear
show_main_menu
