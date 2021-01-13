FROM harbor.huaweicloud.com/ops-manager/jdk8:v1.0.0

MAINTAINER hqj-jenkins

WORKDIR /home

ARG JAR_FILE_PATH

ARG SERVER_PORT

ADD ${JAR_FILE_PATH} app.jar

ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]

EXPOSE ${SERVER_PORT}
