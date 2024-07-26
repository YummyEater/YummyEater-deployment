#!/bin/bash

###볼륨 연결
# 자기 자신의 인스턴스 ID 조회
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "현재 인스턴스의 id = $INSTANCE_ID"

# jenkins_home 볼륨 ID 조회
VOLUME_ID=$(aws ec2 describe-volumes --filters "Name=tag:Name,Values=jenkins_home" --query "Volumes[*].VolumeId" --output text)
echo "jenkins_home ebs volume의 id = $VOLUME_ID"

#jenkins_home 볼륨을 자신과 연결, 장치 이름은 /dev/sdb, ec2 리눅스에는 /dev/xvdb로 인식됨
aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device /dev/sdb
echo "$INSTANCE_ID에 ebs 볼륨 $VOLUME_ID를 연결. 장치 이름은 /dev/sdb. 리눅스에서는 /dev/xvdb로 인식."

#jenkins_home 마운트
mkdir /mnt/jenkins_home
mount /dev/xvdb /mnt/jenkins_home
echo "/dev/xvdb를 /mnt/jenkins_home에 마운트"


###필요한 정보 정의
export DOCKER_IMAGE_PATH="ohretry/yummy-jenkins-linux"

chmod +x ./amazonlinux2023_init_docker.sh ./amazonlinux2023_init_swapfile.sh

#docker 설치
echo "================ 도커 설치 ================"
source ./amazonlinux2023_init_docker.sh
echo "================ 도커 설치 완료 ================"

#swapfile 2GB 설정
echo "================ 스왑메모리 2GB 설정 ================"
source ./amazonlinux2023_init_swapfile.sh
echo "================ 스왑메모리 설정 완료================"


###jenkins 서버 실행
echo "================ jenkins 서버 실행 ================"
echo "jenkins 이미지 = $DOCKER_IMAGE_PATH"

#환경변수를 설정
echo "jenkins container에 넘길 환경변수 설정"

#docker.sock의 그룹인 docker의 gid를 얻어옴
DOCKER_GID=$(getent group docker | cut -d: -f3)
touch ./.env
echo "DOCKER_GID=$DOCKER_GID" >> ./.env
echo "docker 그룹의 id = $DOCKER_GID"

echo "*** jenkins 컨테이너에서 넘겨줄 최종 환경변수 파일 ***"
cat ./.env

# 환경변수를 넘겨주고, jenkins_home volume과 연결, host의 docker socket과 cli 공유, 포트 연결
docker run \
  --env-file ./.env \
  -v /mnt/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which docker):/usr/bin/docker \
  -p 8080:8080 -p 50000:50000 \
  $DOCKER_IMAGE_PATH