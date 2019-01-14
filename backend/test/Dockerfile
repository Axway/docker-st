FROM alpine:latest
RUN apk add --no-cache curl
COPY test.sh .
ENV ST_FQDN 127.0.0.1
CMD [ "./test.sh" ]
