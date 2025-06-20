FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV SELENIUM=/usr/local/bin/selenium-server.jar

COPY selenium-server.jar /usr/local/bin/selenium-server.jar
COPY appium.yaml /usr/local/bin/appium.yaml

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
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest && cd ${ANDROID_SDK_ROOT} && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && rm cmdline-tools.zip && \
    mv cmdline-tools/* cmdline-tools/latest/

ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator:${PATH}"

RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "emulator" "system-images;android-30;google_apis;x86_64" "build-tools;30.0.3"

RUN echo "no" | avdmanager create avd -n pixel_9 -k "system-images;android-30;google_apis;x86_64" --device "pixel"

RUN npm install -g appium@latest && \
    appium driver install uiautomator2 && \
    npm install -g mjpeg-consumer && \
    npm install -g simple-get

EXPOSE 5554 5555 5900 5432

COPY start_emulator.sh /usr/local/bin/start_emulator.sh
RUN chmod +x /usr/local/bin/start_emulator.sh

CMD ["/usr/local/bin/start_emulator.sh"]
