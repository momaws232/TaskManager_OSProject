#!/usr/bin/env python3
"""
Real-time System Monitoring GUI Application
Arab Academy for Science, Technology & Maritime Transport - OS Project 12
"""

import tkinter as tk
from tkinter import ttk, scrolledtext
import subprocess
import json
import threading
import time
from datetime import datetime
import platform

class SystemMonitorGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("System Monitor - AASTMT OS Project 12")
        self.root.geometry("1200x800")
        self.root.configure(bg="#1e1e1e")
        
        # Monitoring state
        self.monitoring = False
        self.update_interval = 2000  # milliseconds
        self.is_windows = platform.system() == "Windows"
        
        # Style configuration
        self.setup_styles()
        
        # Create GUI components
        self.create_header()
        self.create_metrics_section()
        self.create_control_panel()
        self.create_alerts_section()
        self.create_status_bar()
        
        # Start monitoring
        self.start_monitoring()
    
    def setup_styles(self):
        """Configure ttk styles"""
        style = ttk.Style()
        style.theme_use('clam')
        
        # Configure colors
        style.configure("Header.TLabel", 
                       font=("Segoe UI", 24, "bold"),
                       foreground="#4a9eff",
                       background="#1e1e1e")
        
        style.configure("Metric.TLabel",
                       font=("Segoe UI", 12, "bold"),
                       foreground="#ffffff",
                       background="#2d2d2d")
        
        style.configure("Value.TLabel",
                       font=("Segoe UI", 32, "bold"),
                       foreground="#4a9eff",
                       background="#2d2d2d")
        
        style.configure("Small.TLabel",
                       font=("Segoe UI", 10),
                       foreground="#cccccc",
                       background="#2d2d2d")
        
        style.configure("Control.TButton",
                       font=("Segoe UI", 11, "bold"),
                       foreground="#ffffff")
        
        style.configure("TFrame", background="#1e1e1e")
        style.configure("Card.TFrame", background="#2d2d2d", relief="raised")
    
    def create_header(self):
        """Create header section"""
        header_frame = ttk.Frame(self.root)
        header_frame.pack(fill=tk.X, padx=20, pady=10)
        
        title = ttk.Label(header_frame,
                         text="🖥️ Real-Time System Monitor",
                         style="Header.TLabel")
        title.pack(side=tk.LEFT)
        
        subtitle = ttk.Label(header_frame,
                           text="AASTMT - Operating Systems Project 12",
                           font=("Segoe UI", 10),
                           foreground="#888888",
                           background="#1e1e1e")
        subtitle.pack(side=tk.LEFT, padx=20)
    
    def create_metrics_section(self):
        """Create metrics display section"""
        # Main container for metrics
        metrics_container = ttk.Frame(self.root)
        metrics_container.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
        
        # Top row (CPU, Memory, Disk)
        top_row = ttk.Frame(metrics_container)
        top_row.pack(fill=tk.BOTH, expand=True, pady=(0, 10))
        
        self.cpu_card = self.create_metric_card(top_row, "CPU", "💻")
        self.memory_card = self.create_metric_card(top_row, "Memory", "🧠")
        self.disk_card = self.create_metric_card(top_row, "Disk", "💾")
        
        # Bottom row (GPU, Network, System)
        bottom_row = ttk.Frame(metrics_container)
        bottom_row.pack(fill=tk.BOTH, expand=True)
        
        self.gpu_card = self.create_metric_card(bottom_row, "GPU", "🎮")
        self.network_card = self.create_metric_card(bottom_row, "Network", "🌐")
        self.system_card = self.create_metric_card(bottom_row, "System Load", "⚙️")
    
    def create_metric_card(self, parent, title, icon):
        """Create a metric display card"""
        # Card frame
        card_frame = ttk.Frame(parent, style="Card.TFrame")
        card_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5)
        
        # Header with icon and title
        header = ttk.Frame(card_frame, style="Card.TFrame")
        header.pack(fill=tk.X, padx=15, pady=(15, 5))
        
        icon_label = ttk.Label(header, text=icon, font=("Segoe UI", 20),
                              background="#2d2d2d")
        icon_label.pack(side=tk.LEFT)
        
        title_label = ttk.Label(header, text=title, style="Metric.TLabel")
        title_label.pack(side=tk.LEFT, padx=10)
        
        # Main value display
        value_label = ttk.Label(card_frame, text="--", style="Value.TLabel")
        value_label.pack(pady=10)
        
        # Details section
        details_frame = ttk.Frame(card_frame, style="Card.TFrame")
        details_frame.pack(fill=tk.BOTH, expand=True, padx=15, pady=(0, 15))
        
        # Create detail labels
        detail_labels = {}
        for i in range(4):
            label = ttk.Label(details_frame, text="", style="Small.TLabel")
            label.pack(anchor=tk.W, pady=2)
            detail_labels[i] = label
        
        return {
            'frame': card_frame,
            'value': value_label,
            'details': detail_labels
        }
    
    def create_control_panel(self):
        """Create control panel with buttons"""
        control_frame = ttk.Frame(self.root)
        control_frame.pack(fill=tk.X, padx=20, pady=10)
        
        # Control buttons
        self.start_btn = ttk.Button(control_frame,
                                    text="⏸ Pause",
                                    style="Control.TButton",
                                    command=self.toggle_monitoring)
        self.start_btn.pack(side=tk.LEFT, padx=5)
        
        self.report_btn = ttk.Button(control_frame,
                                     text="📊 Generate Report",
                                     style="Control.TButton",
                                     command=self.generate_report)
        self.report_btn.pack(side=tk.LEFT, padx=5)
        
        self.refresh_btn = ttk.Button(control_frame,
                                      text="🔄 Refresh Now",
                                      style="Control.TButton",
                                      command=self.force_refresh)
        self.refresh_btn.pack(side=tk.LEFT, padx=5)
        
        # Interval selector
        ttk.Label(control_frame, text="Update Interval:",
                 font=("Segoe UI", 10),
                 foreground="#ffffff",
                 background="#1e1e1e").pack(side=tk.LEFT, padx=(20, 5))
        
        self.interval_var = tk.StringVar(value="2s")
        interval_combo = ttk.Combobox(control_frame,
                                     textvariable=self.interval_var,
                                     values=["1s", "2s", "5s", "10s"],
                                     width=8,
                                     state="readonly")
        interval_combo.pack(side=tk.LEFT, padx=5)
        interval_combo.bind("<<ComboboxSelected>>", self.change_interval)
    
    def create_alerts_section(self):
        """Create alerts and logs section"""
        alerts_frame = ttk.LabelFrame(self.root, text=" 🚨 Alerts & Activity Log ",
                                     style="Card.TFrame")
        alerts_frame.pack(fill=tk.BOTH, padx=20, pady=10, expand=False)
        
        # Scrolled text widget for logs
        self.alerts_text = scrolledtext.ScrolledText(alerts_frame,
                                                     height=8,
                                                     bg="#1a1a1a",
                                                     fg="#00ff00",
                                                     font=("Consolas", 9),
                                                     wrap=tk.WORD)
        self.alerts_text.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Add initial message
        self.log_message("System Monitor started successfully", "INFO")
    
    def create_status_bar(self):
        """Create status bar"""
        status_frame = ttk.Frame(self.root)
        status_frame.pack(fill=tk.X, side=tk.BOTTOM)
        
        self.status_label = ttk.Label(status_frame,
                                     text="● Monitoring Active",
                                     font=("Segoe UI", 9),
                                     foreground="#00ff00",
                                     background="#1e1e1e")
        self.status_label.pack(side=tk.LEFT, padx=20, pady=5)
        
        self.time_label = ttk.Label(status_frame,
                                   text="",
                                   font=("Segoe UI", 9),
                                   foreground="#888888",
                                   background="#1e1e1e")
        self.time_label.pack(side=tk.RIGHT, padx=20, pady=5)
        
        self.update_time_label()
    
    def run_monitor_command(self, command):
        """Run monitoring script command"""
        try:
            if self.is_windows:
                # Use WSL on Windows
                full_command = f'wsl bash -c "./monitor.sh {command}"'
                result = subprocess.run(full_command,
                                      shell=True,
                                      capture_output=True,
                                      text=True,
                                      cwd=r"d:\Term 5\OSProject",
                                      timeout=10)
            else:
                # Direct bash on Linux
                result = subprocess.run(f"./monitor.sh {command}",
                                      shell=True,
                                      capture_output=True,
                                      text=True,
                                      timeout=10)
            
            return result.stdout
        except Exception as e:
            self.log_message(f"Error running command: {str(e)}", "ERROR")
            return None
    
    def parse_json_output(self, output):
        """Parse JSON output from monitoring script"""
        try:
            # Find JSON in output
            start = output.find('{')
            end = output.rfind('}') + 1
            if start != -1 and end > start:
                json_str = output[start:end]
                return json.loads(json_str)
        except Exception as e:
            self.log_message(f"Parse error: {str(e)}", "ERROR")
        return None
    
    def update_cpu_metrics(self):
        """Update CPU metrics"""
        output = self.run_monitor_command("cpu")
        if output:
            data = self.parse_json_output(output)
            if data:
                usage = float(data.get('cpu_usage', 0))
                self.cpu_card['value'].config(text=f"{usage:.1f}%")
                
                self.cpu_card['details'][0].config(text=f"Cores: {data.get('cpu_cores', 'N/A')}")
                self.cpu_card['details'][1].config(text=f"Load: {data.get('load_average', 'N/A')}")
                self.cpu_card['details'][2].config(text=f"Temp: {data.get('temperature', 'N/A')}°C")
                
                # Check threshold
                if usage > 80:
                    self.cpu_card['value'].config(foreground="#ff4444")
                    self.log_message(f"CPU usage high: {usage:.1f}%", "WARNING")
                else:
                    self.cpu_card['value'].config(foreground="#4a9eff")
    
    def update_memory_metrics(self):
        """Update memory metrics"""
        output = self.run_monitor_command("memory")
        if output:
            data = self.parse_json_output(output)
            if data:
                percent = float(data.get('memory_percent', 0))
                self.memory_card['value'].config(text=f"{percent:.1f}%")
                
                total = data.get('memory_total_mb', 0)
                used = data.get('memory_used_mb', 0)
                available = data.get('memory_available_mb', 0)
                
                self.memory_card['details'][0].config(text=f"Total: {total} MB")
                self.memory_card['details'][1].config(text=f"Used: {used} MB")
                self.memory_card['details'][2].config(text=f"Available: {available} MB")
                
                if percent > 85:
                    self.memory_card['value'].config(foreground="#ff4444")
                    self.log_message(f"Memory usage high: {percent:.1f}%", "WARNING")
                else:
                    self.memory_card['value'].config(foreground="#4a9eff")
    
    def update_disk_metrics(self):
        """Update disk metrics"""
        output = self.run_monitor_command("disk")
        if output:
            data = self.parse_json_output(output)
            if data:
                usage = int(data.get('disk_usage_percent', 0))
                self.disk_card['value'].config(text=f"{usage}%")
                
                self.disk_card['details'][0].config(text=f"Total: {data.get('disk_total', 'N/A')}")
                self.disk_card['details'][1].config(text=f"Used: {data.get('disk_used', 'N/A')}")
                self.disk_card['details'][2].config(text=f"Available: {data.get('disk_available', 'N/A')}")
                self.disk_card['details'][3].config(text=f"SMART: {data.get('smart_status', 'N/A')}")
                
                if usage > 90:
                    self.disk_card['value'].config(foreground="#ff4444")
                    self.log_message(f"Disk usage high: {usage}%", "WARNING")
                else:
                    self.disk_card['value'].config(foreground="#4a9eff")
    
    def update_gpu_metrics(self):
        """Update GPU metrics"""
        output = self.run_monitor_command("gpu")
        if output:
            data = self.parse_json_output(output)
            if data:
                gpu_usage = data.get('gpu_usage', 'N/A')
                if gpu_usage != 'N/A':
                    self.gpu_card['value'].config(text=f"{gpu_usage}%")
                else:
                    self.gpu_card['value'].config(text="N/A")
                
                self.gpu_card['details'][0].config(text=f"Device: {data.get('gpu_name', 'N/A')}")
                self.gpu_card['details'][1].config(text=f"Memory: {data.get('gpu_memory', 'N/A')}")
                self.gpu_card['details'][2].config(text=f"Temp: {data.get('gpu_temperature', 'N/A')}°C")
    
    def update_network_metrics(self):
        """Update network metrics"""
        output = self.run_monitor_command("network")
        if output:
            data = self.parse_json_output(output)
            if data:
                status = data.get('status', 'unknown').upper()
                self.network_card['value'].config(text=status)
                
                if status == 'UP':
                    self.network_card['value'].config(foreground="#00ff00")
                else:
                    self.network_card['value'].config(foreground="#ff4444")
                
                self.network_card['details'][0].config(text=f"Interface: {data.get('interface', 'N/A')}")
                self.network_card['details'][1].config(text=f"IP: {data.get('ip_address', 'N/A')}")
                self.network_card['details'][2].config(text=f"RX: {data.get('rx_mb', 'N/A')} MB")
                self.network_card['details'][3].config(text=f"TX: {data.get('tx_mb', 'N/A')} MB")
    
    def update_system_metrics(self):
        """Update system load metrics"""
        output = self.run_monitor_command("system")
        if output:
            data = self.parse_json_output(output)
            if data:
                load_1min = data.get('load_1min', 'N/A')
                self.system_card['value'].config(text=load_1min)
                
                self.system_card['details'][0].config(text=f"Uptime: {data.get('uptime', 'N/A')}")
                self.system_card['details'][1].config(text=f"Processes: {data.get('total_processes', 'N/A')}")
                self.system_card['details'][2].config(text=f"Running: {data.get('running_processes', 'N/A')}")
                self.system_card['details'][3].config(text=f"Users: {data.get('logged_users', 'N/A')}")
    
    def update_all_metrics(self):
        """Update all metrics in parallel threads"""
        if not self.monitoring:
            return
        
        threads = [
            threading.Thread(target=self.update_cpu_metrics, daemon=True),
            threading.Thread(target=self.update_memory_metrics, daemon=True),
            threading.Thread(target=self.update_disk_metrics, daemon=True),
            threading.Thread(target=self.update_gpu_metrics, daemon=True),
            threading.Thread(target=self.update_network_metrics, daemon=True),
            threading.Thread(target=self.update_system_metrics, daemon=True)
        ]
        
        for thread in threads:
            thread.start()
        
        # Schedule next update
        if self.monitoring:
            self.root.after(self.update_interval, self.update_all_metrics)
    
    def start_monitoring(self):
        """Start monitoring"""
        self.monitoring = True
        self.status_label.config(text="● Monitoring Active", foreground="#00ff00")
        self.update_all_metrics()
    
    def toggle_monitoring(self):
        """Toggle monitoring on/off"""
        if self.monitoring:
            self.monitoring = False
            self.start_btn.config(text="▶ Resume")
            self.status_label.config(text="⏸ Monitoring Paused", foreground="#ff9800")
            self.log_message("Monitoring paused", "INFO")
        else:
            self.monitoring = True
            self.start_btn.config(text="⏸ Pause")
            self.status_label.config(text="● Monitoring Active", foreground="#00ff00")
            self.log_message("Monitoring resumed", "INFO")
            self.update_all_metrics()
    
    def force_refresh(self):
        """Force immediate refresh"""
        self.log_message("Manual refresh triggered", "INFO")
        threading.Thread(target=self.update_all_metrics, daemon=True).start()
    
    def change_interval(self, event=None):
        """Change update interval"""
        interval_str = self.interval_var.get()
        seconds = int(interval_str[:-1])
        self.update_interval = seconds * 1000
        self.log_message(f"Update interval changed to {interval_str}", "INFO")
    
    def generate_report(self):
        """Generate system report"""
        self.log_message("Generating report...", "INFO")
        self.report_btn.config(state="disabled", text="⏳ Generating...")
        
        def run_report():
            output = self.run_monitor_command("report")
            self.root.after(0, lambda: self.report_complete(output))
        
        threading.Thread(target=run_report, daemon=True).start()
    
    def report_complete(self, output):
        """Handle report completion"""
        self.report_btn.config(state="normal", text="📊 Generate Report")
        if output and "reports/" in output:
            self.log_message("Report generated successfully!", "SUCCESS")
        else:
            self.log_message("Failed to generate report", "ERROR")
    
    def log_message(self, message, level="INFO"):
        """Add message to log"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        # Color based on level
        color_map = {
            "INFO": "#00ff00",
            "WARNING": "#ff9800",
            "ERROR": "#ff4444",
            "SUCCESS": "#00ff88"
        }
        
        # Add to text widget
        self.alerts_text.insert(tk.END, f"[{timestamp}] ", "timestamp")
        self.alerts_text.insert(tk.END, f"[{level}] ", level)
        self.alerts_text.insert(tk.END, f"{message}\n")
        
        # Configure tags
        self.alerts_text.tag_config("timestamp", foreground="#888888")
        self.alerts_text.tag_config(level, foreground=color_map.get(level, "#00ff00"))
        
        # Auto-scroll
        self.alerts_text.see(tk.END)
        
        # Limit log size
        lines = int(self.alerts_text.index('end-1c').split('.')[0])
        if lines > 100:
            self.alerts_text.delete(1.0, 2.0)
    
    def update_time_label(self):
        """Update time label"""
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.time_label.config(text=f"Last Update: {current_time}")
        self.root.after(1000, self.update_time_label)

def main():
    """Main entry point"""
    root = tk.Tk()
    app = SystemMonitorGUI(root)
    
    # Handle window close
    def on_closing():
        app.monitoring = False
        root.destroy()
    
    root.protocol("WM_DELETE_WINDOW", on_closing)
    root.mainloop()

if __name__ == "__main__":
    main()
