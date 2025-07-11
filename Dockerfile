# Use Ubuntu 24.04 LTS as the base image
FROM ubuntu:24.04

# Set non-interactive frontend to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages, including bzip2 for tar.bz2 extraction
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
    libgtk-3-0 \
    libdbus-glib-1-2 \
    bzip2 \
    xterm \
    && apt-get clean

# Install Firefox manually via tarball
RUN curl -L https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US -o /tmp/firefox.tar.bz2 && \
    tar -xjf /tmp/firefox.tar.bz2 -C /opt && \
    ln -s /opt/firefox/firefox /usr/bin/firefox && \
    rm /tmp/firefox.tar.bz2

# Clone noVNC from GitHub
RUN git clone https://github.com/novnc/noVNC.git /noVNC

# Generate self-signed SSL certificate for websockify (optional for Render)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /self.pem -out /self.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=localhost"

# Create a custom xstartup script to launch Openbox and useful applications
RUN echo -e "#!/bin/sh\nopenbox &\nfirefox &\nxterm &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Expose port 8080 for noVNC
EXPOSE 8080

# Start VNC server and noVNC
CMD /usr/bin/vncserver -SecurityTypes none -rfbport 5080 -xstartup /root/.vnc/xstartup :1 && \
    sleep 3 && \
    /noVNC/utils/novnc_proxy --vnc 127.0.0.1:5080 --listen 0.0.0.0:8080
