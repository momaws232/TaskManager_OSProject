#!/bin/bash

################################################################################
# Installation Script for System Monitoring Solution
# Arab Academy for Science, Technology & Maritime Transport - OS Project 12
################################################################################

echo "======================================"
echo "System Monitoring Solution Installer"
echo "AASTMT - OS Project 12"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "ℹ $1"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This script requires Linux. Detected: $OSTYPE"
    exit 1
fi

print_success "Running on Linux"

# Check for required commands
print_info "Checking for required dependencies..."

MISSING_DEPS=()

# Check bash
if ! command -v bash &> /dev/null; then
    MISSING_DEPS+=("bash")
fi

# Check basic tools
for cmd in bc grep awk sed; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS+=("$cmd")
    fi
done

# Check dialog or whiptail
if ! command -v dialog &> /dev/null && ! command -v whiptail &> /dev/null; then
    MISSING_DEPS+=("dialog")
fi

# Check optional tools
OPTIONAL_MISSING=()

if ! command -v sensors &> /dev/null; then
    OPTIONAL_MISSING+=("lm-sensors")
fi

if ! command -v smartctl &> /dev/null; then
    OPTIONAL_MISSING+=("smartmontools")
fi

if ! command -v docker &> /dev/null; then
    OPTIONAL_MISSING+=("docker")
fi

# Report missing dependencies
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    print_error "Missing required dependencies: ${MISSING_DEPS[*]}"
    print_info "Install them with: sudo apt-get install ${MISSING_DEPS[*]}"
    echo ""
    read -p "Would you like to install them now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt-get update
        sudo apt-get install -y ${MISSING_DEPS[*]}
    else
        print_warning "Installation cancelled. Please install dependencies manually."
        exit 1
    fi
fi

if [ ${#OPTIONAL_MISSING[@]} -gt 0 ]; then
    print_warning "Optional dependencies missing: ${OPTIONAL_MISSING[*]}"
    print_info "Some features may be limited without these packages."
    echo ""
    read -p "Would you like to install optional dependencies? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt-get install -y ${OPTIONAL_MISSING[*]}
    fi
fi

print_success "All required dependencies are available"

# Make scripts executable
print_info "Making scripts executable..."
chmod +x monitor.sh dashboard.sh 2>/dev/null
print_success "Scripts are now executable"

# Create necessary directories
print_info "Creating necessary directories..."
mkdir -p logs reports data web/templates
print_success "Directories created"

# Check Python for web interface
if command -v python3 &> /dev/null; then
    print_success "Python 3 found"
    
    # Check if requirements.txt exists
    if [ -f requirements.txt ]; then
        print_info "Python dependencies found in requirements.txt"
        read -p "Would you like to install Python dependencies for web interface? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            pip3 install -r requirements.txt
            print_success "Python dependencies installed"
        fi
    fi
else
    print_warning "Python 3 not found. Web interface will not be available."
fi

# Test monitor script
print_info "Testing monitor script..."
if ./monitor.sh cpu > /dev/null 2>&1; then
    print_success "Monitor script is working"
else
    print_error "Monitor script test failed"
fi

# Initialize sensors (if available)
if command -v sensors-detect &> /dev/null; then
    print_info "Sensors detected. You may want to run 'sudo sensors-detect' to configure temperature monitoring."
fi

# Docker check
if command -v docker &> /dev/null; then
    print_success "Docker is installed"
    
    if command -v docker-compose &> /dev/null; then
        print_success "Docker Compose is installed"
        print_info "You can use Docker deployment with: docker-compose up -d"
    else
        print_warning "Docker Compose not found. Install it for Docker deployment."
    fi
else
    print_warning "Docker not installed. You can still use bash scripts directly."
fi

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
print_info "Quick Start Guide:"
echo ""
echo "1. Run single monitoring cycle:"
echo "   ./monitor.sh monitor"
echo ""
echo "2. Launch interactive dashboard:"
echo "   ./dashboard.sh"
echo ""
echo "3. Generate a report:"
echo "   ./monitor.sh report"
echo ""
echo "4. Start continuous monitoring:"
echo "   ./monitor.sh continuous"
echo ""
echo "5. Docker deployment:"
echo "   docker-compose up -d monitor-collector"
echo ""
print_info "For detailed instructions, see:"
echo "  - README.md for overview"
echo "  - INSTALLATION.md for installation details"
echo "  - USER_MANUAL.md for usage guide"
echo ""
print_success "Happy monitoring!"
