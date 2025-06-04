# Use a base image with necessary dependencies
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV PATH="$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    unzip \
    wget \
    libc6-i386 \
    libstdc++6 \
    libglu1-mesa \
    mesa-utils \
    xvfb \
    x11vnc \
    net-tools \
    socat \
    apt-utils \
    git \
    build-essential \
    libpulse0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and install Android SDK Command-line Tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/commandlinetools.zip && \
    unzip -q /tmp/commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/commandlinetools.zip

# Accept Android SDK licenses
RUN yes | sdkmanager --licenses

# Install Android platform tools, build tools, and system image
RUN sdkmanager "platform-tools" "build-tools;34.0.0" "system-images;android-34;google_apis;x86_64"

# Create AVD for Pixel 9 (using a generic AVD name and system image)
# Note: "Pixel 9" is a marketing name. We use a generic AVD configuration.
# For Android 14, we use API level 34.
ENV AVD_NAME="Pixel_9_API_34"
RUN echo no | avdmanager create avd --name "${AVD_NAME}" --package "system-images;android-34;google_apis;x86_64" --tag "google_apis" --abi "x86_64" --force

# Add a script to start the emulator and VNC server
COPY start_emulator.sh /usr/local/bin/start_emulator.sh
RUN chmod +x /usr/local/bin/start_emulator.sh

# Expose VNC port
EXPOSE 5900

# Start the emulator and VNC server
CMD ["/usr/local/bin/start_emulator.sh"]
