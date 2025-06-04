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

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/commandlinetools.zip && \
    unzip -q /tmp/commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/commandlinetools.zip && \
    # Now, with the tools unpacked, the sdkmanager should be in the PATH
    # that was set earlier, or we can explicitly call it with its full path.
    # The 'yes' is piped to accept licenses.
    echo yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses
    
RUN sdkmanager "platform-tools" "build-tools;34.0.0" "system-images;android-34;google_apis;x86_64"

ENV AVD_NAME="Pixel_9_API_34"
RUN echo no | avdmanager create avd --name "${AVD_NAME}" --package "system-images;android-34;google_apis;x86_64" --tag "google_apis" --abi "x86_64" --force


COPY start_emulator.sh /usr/local/bin/start_emulator.sh
RUN chmod +x /usr/local/bin/start_emulator.sh


EXPOSE 5900


CMD ["/usr/local/bin/start_emulator.sh"]
