#!/bin/bash

###필요한 정보 정의
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
#docker.sock의 그룹인 docker의 gid를 얻어옴
DOCKER_GID=$(getent group docker | cut -d: -f3)
#환경변수를 설정
touch ./.env
echo "DOCKER_GID=$DOCKER_GID" >> ./.env
# 환경변수를 넘겨주고, jenkins_home volume과 연결, host의 docker socket과 cli 공유, 포트 연결
docker run \
  --env-file ./.env \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which docker):/usr/bin/docker \
  -p 8080:8080 -p 50000:50000 \
  $DOCKER_IMAGE_PATH