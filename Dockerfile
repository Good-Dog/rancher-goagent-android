FROM openjdk:8-jre-alpine
MAINTAINER Yun Zhi Lin <yun@yunspace.com>

# Set environment
ENV GOCD_VERSION=16.12.0 \
  GOCD_RELEASE=go-agent \
  GOCD_REVISION=4352 \
  GOCD_HOME=/opt/go-agent \
  PATH=$GOCD_HOME:$PATH \
  USER_HOME=/root
ENV GOCD_REPO=https://download.go.cd/binaries/${GOCD_VERSION}-${GOCD_REVISION}/generic \
  GOCD_RELEASE_ARCHIVE=${GOCD_RELEASE}-${GOCD_VERSION}-${GOCD_REVISION}.zip \
  SERVER_WORK_DIR=${GOCD_HOME}/work

# Install and configure gocd
RUN apk add --no-cache --update git curl bash openssh ca-certificates && rm -rf /var/cache/apk/* \
  && mkdir /opt /var/log/go-agent /var/run/go-agent \
  && cd /opt && curl -sSL ${GOCD_REPO}/${GOCD_RELEASE_ARCHIVE} -O && unzip ${GOCD_RELEASE_ARCHIVE} && rm ${GOCD_RELEASE_ARCHIVE} \
  && mv /opt/${GOCD_RELEASE}-${GOCD_VERSION} ${GOCD_HOME} \
  && chmod 774 ${GOCD_HOME}/*.sh \
  && mkdir -p ${GOCD_HOME}/work 

# Add docker-entrypoint script
ADD docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh 

WORKDIR ${GOCD_HOME}

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
