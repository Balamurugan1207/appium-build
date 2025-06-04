FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
# Ensure the PATH is correctly set immediately after SDK tools are placed
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
# We combine these steps into one RUN command to ensure PATH is effective for sdkmanager
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/commandlinetools.zip && \
    unzip -q /tmp/commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    # The commandlinetools.zip extracts into a 'cmdline-tools' subdirectory,
    # so we need to move its contents up to 'latest' to match the PATH.
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/latest/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest/ && \
    rmdir ${ANDROID_SDK_ROOT}/cmdline-tools/latest/cmdline-tools && \
    rm /tmp/commandlinetools.zip

# Accept Android SDK licenses and install necessary components
# Now that cmdline-tools are in place and PATH is set, sdkmanager should work.
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" \
               "platforms;android-34" \
               "system-images;android-34;google_apis;x86_64" \
               "emulator"

# Create AVD for Pixel 9
# Note: Using 'pixel' device definition for a generic Pixel-like experience
RUN echo "no" | avdmanager create avd -n pixel_9 -k "system-images;android-34;google_apis;x86_64" -d "pixel"

# Add the start_emulator.sh script and make it executable
COPY start_emulator.sh /usr/local/bin/start_emulator.sh
RUN chmod +x /usr/local/bin/start_emulator.sh

# Expose VNC port
EXPOSE 5900

# Start the emulator and VNC server
CMD ["/usr/local/bin/start_emulator.sh"]
