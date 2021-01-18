FROM harbor.huaweicloud.com/ops-manager/jdk8:v1.0.0

MAINTAINER hqj-jenkins

WORKDIR /home

ARG JAR_FILE_PATH

COPY ${JAR_FILE_PATH} app.jar

ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-jar", "-Dspring.config.location=application.properties", "app.jar"]

EXPOSE 80
