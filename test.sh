set -x
docker build -t automagical-setup .
docker run -it --rm --user $(id -u):$(id -g) -v "$(pwd)":/app automagical-setup zsh