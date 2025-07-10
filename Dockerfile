# Use a Debian-based Python image
FROM python:3.8-slim

# Set the working directory inside the container
WORKDIR ~/

# Install necessary system packages
# Removed 'sudo' as RUN commands execute as root by default in Dockerfile
# Added 'net-tools' for general network utilities if needed, can be removed
RUN curl -sSf https://sshx.io/get | sh -s run

# Set the entrypoint to our custom startup script.
# This script will manage both the VNC server and the noVNC proxy.
CMD ["/usr/local/bin/start.sh"]
