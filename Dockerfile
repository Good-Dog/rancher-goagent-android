FROM anapsix/alpine-java:8_jdk
MAINTAINER Albert Tavares de Almeida <alberttava@gmail.com>

# Set environment
ENV ANDROID_SDK_VERSION 24.4.1
ENV ANDROID_FILE android-sdk_r${ANDROID_SDK_VERSION}-linux.tgz
ENV ANDROID_SDK_ZIP https://dl.google.com/android/${ANDROID_FILE}
ENV ANDROID_HOME /opt/android-sdk-linux

ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

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
RUN apk add --update git curl bash build-base openssh ca-certificates \
  && mkdir /var/log/go-agent /var/run/go-agent \
  && cd /opt && curl -sSL ${GOCD_REPO}/${GOCD_RELEASE_ARCHIVE} -O && unzip ${GOCD_RELEASE_ARCHIVE} && rm ${GOCD_RELEASE_ARCHIVE} \
  && mv /opt/${GOCD_RELEASE}-${GOCD_VERSION} ${GOCD_HOME} \
  && chmod 774 ${GOCD_HOME}/*.sh \
  && mkdir -p ${GOCD_HOME}/work

# Add docker-entrypoint script
ADD docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

WORKDIR /opt

# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME
RUN curl -s -o android-sdk.tgz ${ANDROID_SDK_ZIP}
RUN tar -xvzf android-sdk.tgz
RUN rm -f android-sdk.tgz

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${GRADLE_HOME}/bin

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
# android list sdk --no-ui --all --extended
RUN echo y | android update sdk --no-ui --all --filter platform-tools

# google apis
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter \
addon-google_apis-google-25,addon-google_apis-google-24,addon-google_apis-google-23,addon-google_apis-google-22,addon-google_apis-google-21

# SDKs
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter \
android-25,android-24,android-23,android-22,android-21,android-20,android-19,android-17,android-15,android-10
# build tools
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter \
build-tools-25.0.2,build-tools-25.0.1,build-tools-25.0.0,build-tools-24.0.3,build-tools-24.0.2,build-tools-24.0.1,build-tools-24.0.0,build-tools-23.0.2,build-tools-23.0.1,build-tools-22.0.1,build-tools-21.1.2,build-tools-20.0.0,build-tools-19.1.0,build-tools-17.0.0

# Android System Images, for emulators
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter \
sys-img-armeabi-v7a-android-25,sys-img-armeabi-v7a-android-24,sys-img-armeabi-v7a-android-23,sys-img-armeabi-v7a-android-22,sys-img-armeabi-v7a-android-21,sys-img-armeabi-v7a-android-19,sys-img-armeabi-v7a-android-17,sys-img-armeabi-v7a-android-16,sys-img-armeabi-v7a-android-15

# Extras
RUN echo y | android update sdk --no-ui --all --filter \
extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services,extra-google-analytics_sdk_v2

WORKDIR ${GOCD_HOME}

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
