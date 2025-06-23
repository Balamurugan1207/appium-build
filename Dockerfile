# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables for non-interactive installations and Android SDK path
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV SELENIUM=/usr/local/bin/selenium-server.jar

# Copy necessary files into the Docker image
# Ensure these files (selenium-server.jar and appium.yaml) are in the same directory as your Dockerfile
COPY selenium-server.jar /usr/local/bin/selenium-server.jar
COPY appium.yaml /usr/local/bin/appium.yaml

# Install required system packages
RUN apt-get update && apt-get install -y \
    curl unzip git wget sudo \
    openjdk-17-jdk \
    libglu1-mesa \
    xvfb x11vnc fluxbox \
    net-tools telnet \
    libpulse0 \
    python3-pip \
    websockify \
    netcat-traditional \
    socat \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Android Command Line Tools with corrected pathing
# Using a newer version for better compatibility (e.g., 11.0.0 from April 2024 or later if available)
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest && cd ${ANDROID_SDK_ROOT} && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d ./temp_cmdline_tools && rm cmdline-tools.zip && \
    mv ./temp_cmdline_tools/cmdline-tools/* cmdline-tools/latest/ && \
    rm -rf ./temp_cmdline_tools

# Set the PATH environment variable to include Android SDK tools directories
ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator:${PATH}"

# Accept Android SDK licenses and install necessary SDK packages
# Updated to Android 34 (latest stable) for platforms and system images
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-34" "emulator" "system-images;android-34;google_apis;x86_64" "build-tools;34.0.0"

# Create and configure the Android Virtual Device (AVD)
# Using Android 34 for the AVD
RUN echo "no" | avdmanager create avd -n pixel_9 -k "system-images;android-34;google_apis;x86_64" --device "pixel"

# Install Appium and its UIAutomator2 driver
RUN npm install -g appium@latest && \
    appium driver install uiautomator2 && \
    npm install -g mjpeg-consumer && \
    npm install -g simple-get

# Expose ports for ADB, emulator console, and VNC
EXPOSE 5554 5555 5900 5432

# Copy the startup script into the image and make it executable
COPY start_emulator.sh /usr/local/bin/start_emulator.sh
RUN chmod +x /usr/local/bin/start_emulator.sh

# Set the entrypoint for the container to run the startup script
CMD ["/usr/local/bin/start_emulator.sh"]
