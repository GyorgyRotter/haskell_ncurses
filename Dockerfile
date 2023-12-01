FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get -y update --fix-missing
RUN useradd -ms /bin/bash gyuri
RUN apt-get update && apt-get install -y \
      sudo \
      && rm -rf /var/lib/apt/lists/*
RUN adduser gyuri sudo
RUN echo "gyuri:root" | chpasswd

# useful tools
RUN apt-get update && apt-get install -y \
      mc \
      bash-completion \
      xauth \
      make \
      htop \
      entr \
      && rm -rf /var/lib/apt/lists/*

# for version control
RUN apt-get update && apt-get install -y \
      git \
      tig \
      && rm -rf /var/lib/apt/lists/*

# to set the locale
RUN apt-get update && apt-get install -y \
      locales locales-all \
      && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# important to use custom ncurses colors
RUN echo "export TERM=xterm-256color" >> /home/gyuri/.bashrc

# Haskell specific packages
#   by installing these packages it is not necessary to have cabal or stack on your system
#   (so for this task it is enough to have a minimal development environment)
RUN apt-get update && apt-get install -y \
      ghc                                \
      libghc-ncurses-dev                 \
      libghc-random-dev                  \
      && rm -rf /var/lib/apt/lists/*

USER gyuri
