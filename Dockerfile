FROM ubuntu

RUN apt-get update -y && apt-get install -y \
    curl \
    git \
    zsh

RUN chsh -s /usr/bin/zsh
ENV SHELL=/usr/bin/zsh

WORKDIR /app

RUN groupadd -r test && useradd -r -g test test
USER test:test

# ENTRYPOINT ./linux-setup.sh