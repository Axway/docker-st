# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2019 Axway Software SA and its affiliates. All rights reserved.
#
FROM alpine:latest
RUN apk add --no-cache curl openssh-client expect
COPY script/ /script/
WORKDIR /script/
CMD [ "/bin/sh","-c", "./testDocker.sh" ]
