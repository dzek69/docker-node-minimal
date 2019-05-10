FROM dzek69/docker-squash

COPY build /create
RUN chmod +x /create/make && ls /create
WORKDIR /create