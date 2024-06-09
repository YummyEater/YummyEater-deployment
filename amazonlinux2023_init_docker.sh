###도커 설치
yum update -y
yum install docker -y
service docker start
usermod -aG docker ec2-user
