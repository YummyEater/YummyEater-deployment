#!/bin/bash

###필요한 정보 정의
#AWS Systems Manager Parameter Store에서 shh,gpg key를 가져옴
aws ssm get-parameter --name "/yummyeater/github/config/git-crypt/gpg/private-key" --with-decryption --query "Parameter.Value" --output text > /keys/config_gitcrypt_gpg_private_key
aws ssm get-parameter --name "/yummyeater/github/config/ssh/private-key" --with-decryption --query "Parameter.Value" --output text > /keys/config_github_ssh_private_key
export DOCKER_IMAGE_PATH="ohretry/yummy-jenkins-linux"

chmod +x ./amazonlinux2023_init_docker.sh ./amazonlinux2023_init_swapfile.sh

#docker 설치
echo "================ 도커 설치 ================"
source ./amazonlinux2023_init_docker.sh
#swapfile 2GB 설정
echo "================ 스왑메모리 2GB 설정 ================"
source ./amazonlinux2023_init_swapfile.sh


###jenkins 서버 실행
echo "================ jenkins 서버 실행 ================"
# host의 docker socket 와 cli 공유.
docker run \
  -v /keys/config_gitcrypt_gpg_private_key:/keys/config_gitcrypt_gpg_private_key \
  -v /keys/config_github_ssh_private_key:/keys/config_github_ssh_private_key \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which docker):/usr/bin/docker \
  -p 8080:8080 -p 50000:50000 \
  $DOCKER_IMAGE_PATH