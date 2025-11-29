#!/usr/bin/env python3
"""
Web Visualization Server for System Monitoring
Arab Academy for Science, Technology & Maritime Transport - OS Project 12
"""

from flask import Flask, render_template, jsonify, send_from_directory
from flask_cors import CORS
import os
import json
import glob
from datetime import datetime
import pandas as pd

app = Flask(__name__)
CORS(app)

# Configuration
LOG_DIR = os.getenv('LOG_DIR', '/app/logs')
REPORT_DIR = os.getenv('REPORT_DIR', '/app/reports')
DATA_DIR = os.getenv('DATA_DIR', '/app/data')
PORT = int(os.getenv('PORT', 8080))


@app.route('/')
def index():
    """Main dashboard page"""
    return render_template('index.html')


@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'service': 'system-monitor-web'
    })


@app.route('/api/metrics/latest')
def get_latest_metrics():
    """Get latest metrics from all categories"""
    try:
        metrics = {}
        
        # Read latest data from CSV files
        metric_files = {
            'cpu': os.path.join(DATA_DIR, 'cpu_metrics.csv'),
            'memory': os.path.join(DATA_DIR, 'memory_metrics.csv'),
            'disk': os.path.join(DATA_DIR, 'disk_metrics.csv'),
            'gpu': os.path.join(DATA_DIR, 'gpu_metrics.csv'),
            'network': os.path.join(DATA_DIR, 'network_metrics.csv'),
            'system': os.path.join(DATA_DIR, 'system_metrics.csv')
        }
        
        for metric_name, file_path in metric_files.items():
            if os.path.exists(file_path):
                try:
                    df = pd.read_csv(file_path, header=None)
                    if not df.empty:
                        latest = df.iloc[-1].tolist()
                        metrics[metric_name] = {
                            'timestamp': latest[0],
                            'data': latest[1:]
                        }
                except Exception as e:
                    metrics[metric_name] = {'error': str(e)}
            else:
                metrics[metric_name] = {'error': 'No data available'}
        
        return jsonify(metrics)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/metrics/history/<metric_type>')
def get_metric_history(metric_type):
    """Get historical data for a specific metric type"""
    try:
        file_path = os.path.join(DATA_DIR, f'{metric_type}_metrics.csv')
        
        if not os.path.exists(file_path):
            return jsonify({'error': 'Metric not found'}), 404
        
        df = pd.read_csv(file_path, header=None)
        
        # Convert to list of dictionaries
        data = df.to_dict('records')
        
        return jsonify({
            'metric_type': metric_type,
            'count': len(data),
            'data': data[-100:]  # Return last 100 entries
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/reports')
def get_reports():
    """Get list of available reports"""
    try:
        if not os.path.exists(REPORT_DIR):
            return jsonify({'reports': []})
        
        reports = []
        for report_file in glob.glob(os.path.join(REPORT_DIR, '*.md')):
            stat = os.stat(report_file)
            reports.append({
                'filename': os.path.basename(report_file),
                'size': stat.st_size,
                'created': datetime.fromtimestamp(stat.st_ctime).isoformat(),
                'modified': datetime.fromtimestamp(stat.st_mtime).isoformat()
            })
        
        # Sort by modified time, newest first
        reports.sort(key=lambda x: x['modified'], reverse=True)
        
        return jsonify({'reports': reports})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/reports/<filename>')
def get_report(filename):
    """Get content of a specific report"""
    try:
        file_path = os.path.join(REPORT_DIR, filename)
        
        if not os.path.exists(file_path) or not filename.endswith('.md'):
            return jsonify({'error': 'Report not found'}), 404
        
        with open(file_path, 'r') as f:
            content = f.read()
        
        return jsonify({
            'filename': filename,
            'content': content
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/logs')
def get_logs():
    """Get list of available log files"""
    try:
        if not os.path.exists(LOG_DIR):
            return jsonify({'logs': []})
        
        logs = []
        for log_file in glob.glob(os.path.join(LOG_DIR, '*.log')):
            stat = os.stat(log_file)
            logs.append({
                'filename': os.path.basename(log_file),
                'size': stat.st_size,
                'created': datetime.fromtimestamp(stat.st_ctime).isoformat(),
                'modified': datetime.fromtimestamp(stat.st_mtime).isoformat()
            })
        
        # Sort by modified time, newest first
        logs.sort(key=lambda x: x['modified'], reverse=True)
        
        return jsonify({'logs': logs})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/logs/<filename>')
def get_log(filename):
    """Get content of a specific log file (last 1000 lines)"""
    try:
        file_path = os.path.join(LOG_DIR, filename)
        
        if not os.path.exists(file_path) or not filename.endswith('.log'):
            return jsonify({'error': 'Log not found'}), 404
        
        # Read last 1000 lines
        with open(file_path, 'r') as f:
            lines = f.readlines()
            content = ''.join(lines[-1000:])
        
        return jsonify({
            'filename': filename,
            'content': content,
            'line_count': len(lines)
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/alerts')
def get_alerts():
    """Get recent alerts and warnings from logs"""
    try:
        alerts = []
        
        # Find the most recent log file
        log_files = glob.glob(os.path.join(LOG_DIR, '*.log'))
        if not log_files:
            return jsonify({'alerts': []})
        
        latest_log = max(log_files, key=os.path.getmtime)
        
        with open(latest_log, 'r') as f:
            for line in f:
                if '[WARNING]' in line or '[ERROR]' in line:
                    alerts.append(line.strip())
        
        # Return last 50 alerts
        return jsonify({
            'alerts': alerts[-50:],
            'count': len(alerts)
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/stats')
def get_stats():
    """Get overall statistics"""
    try:
        stats = {
            'total_reports': len(glob.glob(os.path.join(REPORT_DIR, '*.md'))),
            'total_logs': len(glob.glob(os.path.join(LOG_DIR, '*.log'))),
            'data_files': {}
        }
        
        # Count data points in each metric file
        for metric_type in ['cpu', 'memory', 'disk', 'gpu', 'network', 'system']:
            file_path = os.path.join(DATA_DIR, f'{metric_type}_metrics.csv')
            if os.path.exists(file_path):
                with open(file_path, 'r') as f:
                    stats['data_files'][metric_type] = len(f.readlines())
        
        return jsonify(stats)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    # Create necessary directories
    os.makedirs(LOG_DIR, exist_ok=True)
    os.makedirs(REPORT_DIR, exist_ok=True)
    os.makedirs(DATA_DIR, exist_ok=True)
    
    print(f"Starting System Monitor Web Server on port {PORT}")
    print(f"Log Directory: {LOG_DIR}")
    print(f"Report Directory: {REPORT_DIR}")
    print(f"Data Directory: {DATA_DIR}")
    
    app.run(host='0.0.0.0', port=PORT, debug=False)
