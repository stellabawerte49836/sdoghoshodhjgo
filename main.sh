#!/bin/bash

# Start VNC server on display :1, listening on the specified port.
# -SecurityTypes None: Disables authentication (less secure, but matches request).
# -xstartup: Specifies the command to run for the session (our prepared openbox script).
# We run it in the background using '&' so the script can continue.
echo "Starting VNC server on display :1, listening on port ${VNC_SERVER_PORT}..."
# Using the prepared xstartup script in /root/.vnc
/usr/bin/vncserver :1 -SecurityTypes None -xstartup "/root/.vnc/xstartup" -rfbport ${VNC_SERVER_PORT} &

# Wait a moment for the VNC server to fully initialize
echo "Waiting 3 seconds for VNC server to initialize..."
sleep 3

# Start noVNC proxy.
# --vnc 127.0.0.1:${VNC_SERVER_PORT}: Connects to the VNC server running locally.
# --listen 0.0.0.0:${NOVNC_WEB_PORT}: Listens for incoming web connections on all network interfaces
#                                     at the specified port, making it accessible from outside the container.
# 'exec' replaces the current shell with the noVNC process, which ensures that
# Docker correctly handles signals (like SIGTERM) to stop the container gracefully.
echo "Starting noVNC proxy, listening on 0.0.0.0:${NOVNC_WEB_PORT}..."
exec /app/noVNC/utils/novnc_proxy --vnc 127.0.0.1:${VNC_SERVER_PORT} --listen 0.0.0.0:${NOVNC_WEB_PORT}
