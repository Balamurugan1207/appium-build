#!/bin/bash
# Launch virtual display
Xvfb :0 -screen 0 1080x1920x16 &

# Start window manager and VNC server
fluxbox &
x11vnc -display :0 -forever -nopw &

# Launch headless emulator with KVM acceleration
emulator \
  -avd pixel_34 \
  -no-window \
  -gpu swiftshader_indirect \
  -no-audio \
  -no-boot-anim \
  -accel on \
  -camera-back none \
  -camera-front none \
  -no-snapshot-load \
  -qemu -m 2048 &

# Wait for Android to boot fully
adb wait-for-device

# Enable network ADB access
ADBKEY="$ADBKEY_PATH" \
  && adb tcpip 5555

# Start noVNC
git clone https://github.com/novnc/noVNC /opt/noVNC && \
  /opt/noVNC/utils/novnc_proxy --vnc localhost:5900 &

wait -n
