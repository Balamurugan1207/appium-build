FROM amrka/ultimate-android:latest

COPY selenium-server.jar /usr/local/bin/selenium-server.jar

ENV SELENIUM=/usr/local/bin/selenium-server.jar

RUN chmod +x $SELENIUM && \
    npm install -g appium && \
    appium driver install uiautomator2

EXPOSE 4723 5900 4444

CMD ["/bin/bash"]
