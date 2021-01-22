FROM harbor.huaweicloud.com/ops-manager/jdk8:v1.0.1

MAINTAINER hqj-jenkins

WORKDIR /home

ARG JAR_FILE_PATH

COPY ${JAR_FILE_PATH} app.jar

ENTRYPOINT ["java",  "-javaagent:elastic-apm-agent-1.20.0.jar",         \
            "-Delastic.apm.server_urls=http://192.168.0.229:8200",      \
            "-Delastic.apm.application_packages=org.springframework" ,  \
            "-XX:+UnlockExperimentalVMOptions",                         \
            "-XX:+UseCGroupMemoryLimitForHeap",                         \
            "-jar", "-Dspring.config.location=application.properties",  \
            "/home/app.jar"]

EXPOSE 80
