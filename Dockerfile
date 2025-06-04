FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    unzip \
    git \
    curl \
    libglu1-mesa \
    libpulse0 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libnss3 \
    libxrandr2 \
    libxcursor1 \
    libxcomposite1 \
    libasound2 \
    libxi6 \
    libdbus-glib-1-2 \
    libqt5widgets5 \
    libqt5gui5 \
    libqt5core5a \
    xvfb \
    x11vnc \
    fluxbox \
    && rm -rf /var/lib/apt/lists/*

# Create Android SDK directory
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools

# Download and install Android command line tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm cmdline-tools.zip

# Accept licenses and install SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-34" "system-images;android-34;google_apis;x86_64" "emulator"

# Create Android Virtual Device (AVD)
RUN echo "no" | avdmanager create avd -n pixel_9 -k "system-images;android-34;google_apis;x86_64" -d "pixel"

# Expose VNC port
EXPOSE 5900

# Start VNC server and emulator
CMD xvfb-run --server-args="-screen 0 1280x720x24" bash -c "x11vnc -forever -usepw -create & emulator -avd pixel_9 -no-audio -no-boot-anim -gpu swiftshader_indirect -verbose"
