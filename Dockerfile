# See the associated GitHub workflow, that builds and publishes
# this docker image to Docker Hub:
# .github/workflows/publish-builder-img.yml
# It can be triggered manually from the GitHub project page. 

FROM node:12.19.0-stretch
RUN apt-get update && apt-get install -y libxkbfile-dev libsecret-1-dev && apt-get clean

COPY scripts/uid_entrypoint /usr/local/bin/uid_entrypoint
RUN chmod u+x /usr/local/bin/uid_entrypoint && \
    chgrp 0 /usr/local/bin/uid_entrypoint && \
    chmod g=u /usr/local/bin/uid_entrypoint /etc/passwd

ENTRYPOINT [ "uid_entrypoint" ]

# XVNC dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      libgtk-3-0 \
      tightvncserver \
      metacity \
      x11-xserver-utils \
      libgl1-mesa-dri \
      xfonts-base \
      xfonts-scalable \
      xfonts-100dpi \
      xfonts-75dpi \
      fonts-liberation \
      fonts-freefont-ttf \
      fonts-dejavu \
      fonts-dejavu-core \
      fonts-dejavu-extra \
    && apt-get clean

# dependencies for running theia blueprint
RUN apt-get update && apt-get install -y --no-install-recommends \
      libxss1 \
      libxtst6 \
      libnss3 \
      libatk-bridge2.0-0 \
      libasound2 \
    && apt-get clean


RUN mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

ENV USER_NAME jenkins
ENV HOME /home/jenkins/
ENV DISPLAY :0

RUN mkdir -p /home/jenkins/.vnc && chmod -R 775 /home/jenkins \
  && echo "123456" | vncpasswd -f > /home/jenkins/.vnc/passwd \
  && chmod 600 /home/jenkins/.vnc/passwd

# Create a custom vnc xstartup file
COPY scripts/xstartup_metacity.sh /home/jenkins/.vnc/xstartup.sh
RUN chmod 755 /home/jenkins/.vnc/xstartup.sh

WORKDIR /home/jenkins

USER USER 10001:0