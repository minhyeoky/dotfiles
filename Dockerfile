FROM ubuntu:latest

ARG USER=docker
ARG HOME=/home/$USER

RUN apt update
RUN apt install -y git
RUN apt install -y python3
RUN apt install -y sudo

# Install Vim
RUN apt install -y vim

# Create User
RUN useradd $USER
RUN usermod -aG sudo $USER
RUN echo "$USER:$USER" | chpasswd
RUN mkdir -p $HOME && chown -R $USER:$USER $HOME 
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER $USER
WORKDIR $HOME

# Clone dotfiles
RUN git clone https://github.com/minhyeoky/dotfiles.git
WORKDIR ${HOME}/dotfiles


