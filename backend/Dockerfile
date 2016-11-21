FROM openjdk:8

RUN wget https://services.gradle.org/distributions/gradle-3.2-bin.zip && unzip gradle-3.2-bin.zip

ENV CASSANDRA_CONTACT_POINT 127.0.0.1

COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
RUN /gradle-3.2/bin/gradle install

CMD ["build/install/todo-backend/bin/todo-backend"]
