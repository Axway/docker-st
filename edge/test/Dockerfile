FROM alpine:latest
RUN apk add --no-cache curl openssh-client expect
COPY script/ /script/
WORKDIR /script/
CMD [ "/bin/sh","-c", "./testDocker.sh" ]
