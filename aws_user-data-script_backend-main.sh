#!/bin/bash

###필요한 정보 정의
#AWS Systems Manager Parameter Store에서 shh,gpg key를 가져옴
GPG_PRIVATE_KEY=$(aws ssm get-parameter --name "/yummyeater/github/config/git-crypt/gpg/private-key" --with-decryption --query "Parameter.Value" --output text)
SSH_PRIVATE_KEY=$(aws ssm get-parameter --name "/yummyeater/github/config/ssh/private-key" --with-decryption --query "Parameter.Value" --output text)
#기타 변수
CONFIG_REPOSITORY_SSH_ADDRESS="git@github.com:YummyEater/YummyEater-config.git"
CONFIG_REPOSITORY_NAME="YummyEater-config"
CONFIG_ENVFILE_PATH="config/backend-main.env"
DOCKER_IMAGE_PATH="ohretry/yummy-backend"



###도커 설치
yum update -y
yum install docker -y
service docker start
usermod -aG docker ec2-user



###gcc, make, perl, git, aws-cli 설치
yum install -y gcc-c++ make perl git aws-cli
###amazon linux 2023의 기본 패키지인 gnupg2-minimal에서 gpg-agent를 이용하기 위해 업그레이드
dnf install -y --allowerasing gnupg2-full

###ssh-agent 실행
eval $(ssh-agent -s)

###gpg-agent 실행
eval $(gpg-agent --daemon)



###openssl 1.1.1 빌드 및 설치(git-crypt와 openssl3.0이 호환되지 않음)
#소스 코드를 다운로드
wget https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
#압축 해제
tar -zxvf openssl-1.1.1w.tar.gz
cd openssl-1.1.1w
#시스템에 맞춰 컴파일러 옵션이나 Makefile등을 만드는 과정
./config
#빌드
make
#설치
make install
#yum을 통하지 않은 직접 설치이므로 동적 링크 로더가 찾을 수 있도록 환경변수 추가
export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH
#디렉터리를 되돌림
cd ..



###git-crypt 설치
#실행 바이너리를 다운로드
wget https://github.com/AGWA/git-crypt/releases/download/0.7.0/git-crypt-0.7.0-linux-x86_64
#실행 권한 부여
chmod +x git-crypt-0.7.0-linux-x86_64
#모든 사용자가 이용 가능하도록 전역 디렉터리로 이동
mv git-crypt-0.7.0-linux-x86_64 /usr/local/bin/git-crypt



###스왑메모리 설정
#/swapfile을 생성하고 128MB 블록 사이즈로 16개의 블록 즉 2GM를 할당
dd if=/dev/zero of=/swapfile bs=128M count=16
#/swapfile을 root만 읽고 쓸수 있게 함.(보안)
chmod 600 /swapfile
#/swapfile을 스왑 영역으로 설정
mkswap /swapfile
#/swapfile을 시스템에 활성 스왑 공간으로 설정. 여기서부터 스왑 메모리로 사용되기 시작.
swapon /swapfile
#/etx/fstab에 스왑 파일 정보를 추가. 재부팅 시에도 스왑 파일이 유지되도록 함
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
#free -m의 swap공간을 확인해서 2GB가 할당되었는지 확인 가능



###백엔드 환경변수를 Config Repository에서 clone
#GPG key를 gpg key ring에 등록
echo "$GPG_PRIVATE_KEY" | gpg --import

#ssh key를 ssh-agent에 등록
echo "$SSH_PRIVATE_KEY" | ssh-add -
#known host에 등록
mkdir -p ~/.ssh
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

#Clone Config Repository
git clone $CONFIG_REPOSITORY_SSH_ADDRESS
cd $CONFIG_REPOSITORY_NAME
#git-crypt로 Config 레포지토리를 복호화
git-crypt unlock
#디렉터리를 되돌림
cd ..



###백엔드 서버 실행
docker run --env-file $CONFIG_REPOSITORY_NAME/$CONFIG_ENVFILE_PATH -p 8080:8080 $DOCKER_IMAGE_PATH
