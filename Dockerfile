# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set non-interactive frontend to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    build-essential \
    cmake \
    make \
    firefox \
    kitty \
    fluxbox \
    openbox \
    tigervnc-standalone-server \
    git \
    xterm \
    websockify \
    qemu-kvm \
    qemu-system-x86 \
    tint2 \
    openssl \
    && apt-get clean

# Clone noVNC from GitHub
RUN git clone https://github.com/novnc/noVNC.git /noVNC

# Generate self-signed SSL certificate for websockify
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /self.pem -out /self.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=localhost"

# Expose port 8080 for noVNC
EXPOSE 8080

# Start VNC server and noVNC with SSL
CMD /usr/bin/vncserver -SecurityTypes none -rfbport 5080 -xstartup /usr/bin/openbox :1 && \
    sleep 3 && \
    /noVNC/utils/novnc_proxy --vnc 127.0.0.1:5080 --listen 0.0.0.0:8080 --cert /self.pem --key /self.pem
