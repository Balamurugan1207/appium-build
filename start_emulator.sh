#!/bin/bash

# Start Xvfb (virtual framebuffer)
Xvfb :10 -screen 0 1280x768x24 &
export DISPLAY=:10

# Start the emulator in the background
# -no-window: Ensures the emulator doesn't try to open a GUI window
# -gpu swiftshader_indirect: Software rendering for better compatibility in Docker
# -no-audio: Disable audio to avoid issues
# -no-boot-anim: Disable boot animation for faster startup
# -qemu -monitor tcp::5554,server,nowait: Optional, for qemu monitor access
emulator -avd "${AVD_NAME}" -no-window -gpu swiftshader_indirect -no-audio -no-boot-anim &

# Wait for the emulator to boot
# You might need to adjust this sleep time or add a more robust check (e.g., adb wait-for-device)
echo "Waiting for emulator to boot..."
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'
echo "Emulator booted."

# Start VNC server
x11vnc -display :10 -forever -usepw -noipv6 -rfbport 5900 -shared -N &

echo "VNC server started on port 5900"

# Keep the container running
tail -f /dev/null
