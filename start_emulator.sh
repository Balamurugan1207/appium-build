#!/bin/bash
set -e

Xvfb :0 -screen 0 1080x1920x16 &
fluxbox &
x11vnc -display :0 -nopw -forever &

emulator -avd pixel_34 \
  -no-window \
  -gpu swiftshader_indirect \
  -no-snapshot \
  -wipe-data \
  -delay-adb \
  -accel on \
  -no-audio \
  -no-boot-anim &

# Wait for actual boot.
until adb shell getprop sys.boot_completed | grep -m1 '1'; do
  echo "⏳ Waiting boot complete..."
  sleep 2
done

adb kill-server
adb start-server

until adb connect localhost:5555 && adb devices | grep -w "127.0.0.1:5555\|localhost:5555"; do
  echo "🔁 Retrying ADB connect..."
  sleep 1
done

adb tcpip 5555

git clone --depth=1 https://github.com/novnc/noVNC.git /opt/noVNC
/opt/noVNC/utils/novnc_proxy --vnc localhost:5900 &

wait -n
