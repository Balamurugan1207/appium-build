FROM openjdk:17-jdk-slim

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_SDK_ROOT=/opt/android/sdk \
    PATH="${PATH}:/opt/android/sdk/cmdline-tools/latest/bin:/opt/android/sdk/emulator:/opt/android/sdk/platform-tools"

RUN apt-get update && apt-get install -y \
    wget unzip xvfb x11vnc fluxbox git curl libgl1-mesa-dev qemu-kvm \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools" && \
    wget -qO /tmp/cmdline.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip /tmp/cmdline.zip -d "${ANDROID_SDK_ROOT}/cmdline-tools" && \
    mv "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" "${ANDROID_SDK_ROOT}/cmdline-tools/latest" && \
    rm /tmp/cmdline.zip

RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install \
    "platform-tools" "emulator" "system-images;android-34;google_apis_playstore;x86_64" && \
    yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses

RUN echo no | avdmanager create avd \
    --name pixel_34 \
    --package "system-images;android-34;google_apis_playstore;x86_64" \
    --device "pixel"

COPY start_emulator.sh /usr/local/bin/start_emulator.sh
RUN chmod +x /usr/local/bin/start_emulator.sh

EXPOSE 5555 6080

ENTRYPOINT ["/usr/local/bin/start_emulator.sh"]
