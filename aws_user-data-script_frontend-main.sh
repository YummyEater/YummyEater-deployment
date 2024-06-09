#!/bin/bash

###필요한 정보 정의
#AWS Systems Manager Parameter Store에서 shh,gpg key를 가져옴
export CONFIG_REPOSITORY_GITCRYPT_GPG_PRIVATEKEY=$(aws ssm get-parameter --name "/yummyeater/github/config/git-crypt/gpg/private-key" --with-decryption --query "Parameter.Value" --output text)
export CONFIG_REPOSITORY_SSH_PRIVATEKEY=$(aws ssm get-parameter --name "/yummyeater/github/config/ssh/private-key" --with-decryption --query "Parameter.Value" --output text)
export CONFIG_REPOSITORY_SSH_ADDRESS="git@github.com:YummyEater/YummyEater-config.git"
export CONFIG_REPOSITORY_NAME="YummyEater-config"
export CONFIG_REPOSITORY_ENVFILE_PATH="config/frontend-main.env"
export DOCKER_IMAGE_PATH="ohretry/yummy-frontend"

#실행권한 부여
chmod +x ./amazonlinux2023_init_docker.sh ./amazonlinux2023_init_ssh.sh ./amazonlinux2023_init_gpg.sh ./amazonlinux2023_init_openssl.sh ./amazonlinux2023_init_git-crypt.sh ./amazonlinux2023_init_swapfile.sh ./clone-decrypt_config-repository.sh
#docker 설치
echo "================ 도커 설치 ================"
source ./amazonlinux2023_init_docker.sh
#ssh 초기화, ssh-agent 시작
echo "================ ssh 설정 ================"
source ./amazonlinux2023_init_ssh.sh
#gpg 설치, gpg-agent 시작
echo "================ gpg 설정 ================"
source ./amazonlinux2023_init_gpg.sh
#openssl 설치
echo "================ openssl 설치 ================"
source ./amazonlinux2023_init_openssl.sh
#git-crypt 설치
echo "================ git-crypt 설치 ================"
source ./amazonlinux2023_init_git-crypt.sh
#swapfile 2GB 설정
echo "================ 스왑메모리 2GB 설정 ================"
source ./amazonlinux2023_init_swapfile.sh

#config 레포지토리를 clone하고 git-crypt 복호화
echo "================ Config 레포지토리 클론 & 복호화 ================"
./clone-decrypt_config-repository.sh

###백엔드 서버 실행
echo "================ 프론트엔드 서버 실행 ================"
docker run --env-file $CONFIG_REPOSITORY_NAME/$CONFIG_REPOSITORY_ENVFILE_PATH -p 3000:3000 $DOCKER_IMAGE_PATH
