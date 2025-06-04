FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT="/opt/android-sdk"

ENV PATH="$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"


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

RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm cmdline-tools.zip

RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-34" "system-images;android-34;google_apis;x86_64" "emulator"


RUN echo "no" | avdmanager create avd -n pixel_9 -k "system-images;android-34;google_apis;x86_64" -d "pixel"


COPY start_emulator.sh /usr/local/bin/start_emulator.sh
RUN chmod +x /usr/local/bin/start_emulator.sh


EXPOSE 5900


CMD ["/usr/local/bin/start_emulator.sh"]
