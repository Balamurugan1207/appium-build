#!/bin/bash

ANDROID_SDK_ROOT=/opt/android-sdk

echo "Starting Xvfb, Fluxbox, and X11VNC..."
xvfb-run --server-args='-screen 0 1280x720x24' bash -c 'fluxbox & x11vnc -forever -create -display :99 -rfbport 5900 &' &

VNC_PID=$!

echo "Starting Android emulator..."
# Updated to use AVD for Android 34 (pixel_9 from Dockerfile)
$ANDROID_SDK_ROOT/emulator/emulator -avd pixel_9 -no-audio -no-boot-anim -gpu host -verbose -no-snapshot-load -no-snapshot-save &

EMULATOR_PID=$!

ADB_PORT=5555
TIMEOUT=600

echo "Waiting for ADB daemon to become active on port $ADB_PORT..."
start_time=$(date +%s)
until netcat -z -w 5 localhost $ADB_PORT; do
    elapsed_time=$(($(date +%s) - $start_time))
    if [ "$elapsed_time" -ge "$TIMEOUT" ]; then
        echo "Error: ADB daemon did not become active on port $ADB_PORT within $TIMEOUT seconds."
        exit 1
    fi
    echo "Still waiting for ADB on port $ADB_PORT... ($elapsed_time/${TIMEOUT}s elapsed)"
    sleep 5
done

echo "ADB daemon is listening on port $ADB_PORT!"
echo "Verifying ADB devices from inside container:"
adb devices

echo "Emulator and ADB are fully running. Keeping container alive..."
tail -f /dev/null
