# Use a Debian-based Python image
FROM python:3.8-slim

# Set the working directory inside the container
WORKDIR /app

# Install necessary system packages
# Removed 'sudo' as RUN commands execute as root by default in Dockerfile
# Added 'net-tools' for general network utilities if needed, can be removed
RUN apt update && apt install -y \
  build-essential \
  cmake \
  curl \
  wget \
  git \
  firefox-esr \
  kitty \
  xterm \
  fluxbox \
  openbox \
  tint2 \
  tigervnc-standalone-server \
  websockify \
  qemu-kvm \
  net-tools

# Clone noVNC repository
RUN git clone https://github.com/novnc/noVNC.git

# Create a basic xstartup script for the VNC server.
# This script will be executed when the VNC server starts for a display.
# Since we're running as root (default in Docker), the config goes in /root/.vnc
RUN mkdir -p /root/.vnc && \
    echo '#!/bin/sh' > /root/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup && \
    echo 'openbox &' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Expose ports:
# 8080 for the noVNC web interface (HTTP/WebSocket)
# 5080 for direct VNC connection (if you were to use a VNC client directly)
ENV NOVNC_WEB_PORT=8080
ENV VNC_SERVER_PORT=5080
EXPOSE ${NOVNC_WEB_PORT}
EXPOSE ${VNC_SERVER_PORT}

# Copy the startup script into the container and make it executable
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Set the entrypoint to our custom startup script.
# This script will manage both the VNC server and the noVNC proxy.
CMD ["/usr/local/bin/start.sh"]
