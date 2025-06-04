FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV SELENIUM=/usr/local/bin/selenium-server.jar

COPY selenium-server.jar /usr/local/bin/selenium-server.jar

# Install required packages
RUN apt-get update && apt-get install -y \
    curl unzip git wget sudo \
    openjdk-17-jdk \
    libglu1-mesa \
    xvfb x11vnc fluxbox \
    net-tools telnet \
    libpulse0 \
    && rm -rf /var/lib/apt/lists/*

# Install Android Command Line Tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && cd ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip && \
    unzip tools.zip && rm tools.zip && mv cmdline-tools latest && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest

ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator:${PATH}"

# Accept licenses and install required packages
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "emulator" "system-images;android-30;google_apis;x86_64"

# Create and configure AVD
RUN echo "no" | avdmanager create avd -n pixel_9 -k "system-images;android-30;google_apis;x86_64" --device "pixel"

RUN npm install -g appium@latest && appium driver install uiautomator2

# Expose necessary ports for ADB and VNC
EXPOSE 5554 5555 5900

# Start emulator with VNC and xvfb
CMD xvfb-run --server-args="-screen 0 1280x720x24" bash -c "\
    x11vnc -forever -create & \
    emulator -avd pixel_9 -no-audio -no-boot-anim -gpu swiftshader_indirect -verbose"
