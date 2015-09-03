FROM java:8-jre
MAINTAINER Casey Harford <casey.harford@weebly.com>

ADD app /app
WORKDIR /app

RUN wget http://selenium-release.storage.googleapis.com/2.45/selenium-server-standalone-2.45.0.jar
RUN wget http://central.maven.org/maven2/redis/clients/jedis/2.7.2/jedis-2.7.2.jar
RUN wget http://central.maven.org/maven2/com/googlecode/json-simple/json-simple/1.1/json-simple-1.1.jar

CMD ["java", "-cp", "*:.", "org.openqa.grid.selenium.GridLauncher", "-role", "hub", "-throwOnCapabilityNotPresent", "false", "-newSessionWaitTimeout", "900000"]
