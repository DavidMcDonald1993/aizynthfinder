#!/bin/bash

DOCKER_IMAGE_NAME=davidmcdonald93/retrosynthetic_planning

sudo docker build -t ${DOCKER_IMAGE_NAME} .
sudo docker push ${DOCKER_IMAGE_NAME}

# sudo docker rm $(sudo docker ps --filter=status=exited --filter=status=created -q)
# sudo docker rmi $(sudo docker images -a --filter=dangling=true -q)