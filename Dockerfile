# 1. Base image with minimal OS and JDK
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_SDK_ROOT=/opt/android/sdk \
    PATH="$PATH:/opt/android/cmdline-tools/latest/bin:/opt/android/sdk/emulator:/opt/android/sdk/platform-tools"

# 2. Install dependencies
RUN apt-get update && apt-get install -y \
    wget unzip curl xvfb x11vnc fluxbox \
    libgl1-mesa-dev libpulse0 libx11-dev libxrandr-dev \
    qemu-kvm libvirt-clients libvirt-daemon-system && \
    rm -rf /var/lib/apt/lists/*

# 3. Download Android command-line tools
RUN mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools" && \
    wget -qO /tmp/tools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip /tmp/tools.zip -d "$ANDROID_SDK_ROOT/cmdline-tools/latest" && \
    rm /tmp/tools.zip

# 4. Accept licenses & install SDK components
RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platform-tools" "emulator" && \
    sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "system-images;android-34;google_apis_playstore;x86_64"

# 5. Create AVD (Pixel 4 profiles are default Pixel form)
RUN echo no | avdmanager create avd \
    --name pixel_34 \
    --package "system-images;android-34;google_apis_playstore;x86_64" \
    --device "pixel" \
    --force

# 6. Set environment variables
ENV ADBKEY_PATH=/root/.android/adbkey

# 7. Copy startup script
COPY start_emulator.sh /usr/local/bin/start_emulator.sh
RUN chmod +x /usr/local/bin/start_emulator.sh

# 8. Expose ports
EXPOSE 5555 6080

# 9. Default command
ENTRYPOINT ["/usr/local/bin/start-emulator.sh"]
