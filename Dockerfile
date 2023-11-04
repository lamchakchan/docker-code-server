FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

RUN \
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    ca-certificates \
    curl \
    golang \
    git \
    gnupg \
    jq \
    libatomic1 \
    nano \
    net-tools \
    netcat \
    sudo \
    vim \
    wget \ 
    xz-utils \
    zsh && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  echo "**** clean up ****" && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
# -t robbyrussell \
# -a 'CASE_SENSITIVE="true"' \
# -p https://github.com/zsh-users/zsh-autosuggestions \
# -p https://github.com/zsh-users/zsh-completions

# # https://deb.nodesource.com/
# RUN \
#   curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
#   NODE_MAJOR=20 && \
#   echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list && \
#   apt-get update && sudo apt-get install nodejs -y && \
#     echo "**** clean up ****" && \
#   apt-get clean && \
#   rm -rf \
#     /config/* \
#     /tmp/* \
#     /var/lib/apt/lists/* \
#     /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 8443

