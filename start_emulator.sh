#!/bin/bash
set -e

# Start virtual X display
Xvfb :0 -screen 0 1080x1920x16 &

# Window manager + VNC server
fluxbox &
x11vnc -display :0 -nopw -forever &

# Launch emulator
emulator -avd pixel_34 \
  -no-window \
  -gpu swiftshader_indirect \
  -accel on \
  -no-audio \
  -no-boot-anim &

# Wait for boot
adb wait-for-device

# Expose ADB over TCP
adb tcpip 5555

# Start noVNC for browser access
git clone --depth=1 https://github.com/novnc/noVNC.git /opt/noVNC
/opt/noVNC/utils/novnc_proxy --vnc localhost:5900 &

# Keep container alive
wait -n
