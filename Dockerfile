# Dockerfile for System Monitoring Application
# Arab Academy for Science, Technology & Maritime Transport - OS Project 12

FROM ubuntu:22.04

# Metadata
LABEL maintainer="AASTMT OS Project Team"
LABEL description="System Monitoring Container with monitoring tools and dashboard"
LABEL version="1.0"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    procps \
    sysstat \
    net-tools \
    iproute2 \
    dialog \
    whiptail \
    bc \
    curl \
    wget \
    lm-sensors \
    smartmontools \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Create necessary directories
RUN mkdir -p /app/logs /app/reports /app/data

# Copy monitoring scripts
COPY monitor.sh /app/
COPY dashboard.sh /app/

# Make scripts executable
RUN chmod +x /app/monitor.sh /app/dashboard.sh

# Create a startup script
RUN echo '#!/bin/bash\n\
echo "System Monitor Container Started"\n\
echo "Available commands:"\n\
echo "  ./monitor.sh monitor    - Run single monitoring cycle"\n\
echo "  ./monitor.sh continuous - Run continuous monitoring"\n\
echo "  ./monitor.sh report     - Generate report"\n\
echo "  ./dashboard.sh          - Launch interactive dashboard"\n\
echo ""\n\
exec "$@"' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Default command
CMD ["bash"]
