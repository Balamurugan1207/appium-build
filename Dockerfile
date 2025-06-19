FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV SELENIUM=/usr/local/bin/selenium-server.jar

# Copy dependencies
COPY selenium-server.jar /usr/local/bin/selenium-server.jar
COPY appium.yaml /usr/local/bin/appium.yaml

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl unzip git wget sudo \
    openjdk-17-jdk \
    libglu1-mesa \
    xvfb x11vnc fluxbox \
    net-tools telnet \
    libpulse0 \
    python3-pip \
    websockify \
    socat \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Android Command Line Tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && cd ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip && \
    unzip tools.zip && rm tools.zip && mv cmdline-tools latest && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest

ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator:${PATH}"

# Accept licenses and install SDK packages
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "emulator" \
               "system-images;android-30;google_apis;x86_64" "build-tools;30.0.3"

# Create an AVD (device)
RUN echo "no" | avdmanager create avd -n pixel_9 \
    -k "system-images;android-30;google_apis;x86_64" --device "pixel"

# Install Appium and related tools
RUN npm install -g appium@latest && \
    appium driver install uiautomator2 && \
    npm install -g mjpeg-consumer simple-get

# Expose necessary ports
EXPOSE 5554 5555 5900

# Start emulator, ADB over TCP, and keep container running
CMD bash -c "\
    xvfb-run --server-args='-screen 0 1280x720x24' bash -c '\
        fluxbox & \
        x11vnc -forever -create -display :99 -rfbport 5900 & \
        $ANDROID_SDK_ROOT/emulator/emulator -avd pixel_9 \
            -no-audio -no-boot-anim -gpu swiftshader_indirect -no-snapshot -no-window \
            -port 5554 '"
