# Use Ubuntu 24.04 LTS as the base image
FROM ubuntu:24.04

# Set non-interactive frontend to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    build-essential \
    cmake \
    make \
    kitty \
    openbox \
    tigervnc-standalone-server \
    git \
    websockify \
    qemu-kvm \
    qemu-system-x86 \
    tint2 \
    openssl \
    xterm \
    gnupg \
    ca-certificates \
    && apt-get clean

# Add Google Chrome repository and install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    apt-get clean

# Clone noVNC from GitHub
RUN git clone https://github.com/novnc/noVNC.git /noVNC

# Generate self-signed SSL certificate for websockify (optional for Render)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /self.pem -out /self.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=localhost"

# Expose port 8080 for noVNC
EXPOSE 8080

# Start VNC server and noVNC
CMD /usr/bin/vncserver -SecurityTypes none -rfbport 5080 -xstartup "openbox" :1 && \
    sleep 3 && \
    /noVNC/utils/novnc_proxy --vnc 127.0.0.1:5080 --listen 0.0.0.0:8080
