#!/bin/bash
# docker out of docker 방식으로 host의 docker.sock을 공유할 경우 docker.sock의 소유자와 그룹 정보는 host의 정보를 그대로 가져오게 된다.
# 따라서 host의 docker그룹의 gid를 환경변수로 공유받아서 docker그룹을 생성하고 jenkins유저를 추가해 주도록 한다.
# 그래야 docker 그룹에 속해서 컨테이너 내부에서 docker.sock에 읽기, 쓰기 권한이 생긴다.
groupadd -g $DOCKER_GID docker
usermod -aG docker jenkins
# jenkins_home을 docker volume을 사용하지 않고 bind mount를 했을 경우,
# host의 소유자와 권한을 그대로 가져가기 때문에 jenkins 유저는 접근 권한이 없을 수 있다.
# 따라서 가능하면 /var/jenkins_home의 소유자를 jenkins로 변경하고 읽기, 쓰기, 실행 권한을 부여한다
chown -R jenkins:jenkins /var/jenkins_home
# 소유자, 그룹 = r w x, 그외 = r x
chmod -R 775 /var/jenkins_home
# 현재 쉘의 환경 변수를 유지하면서(-m 옵션) jenkins 사용자로 변경하고 시작 스크립트를 실행
exec su -m jenkins -c "/usr/local/bin/jenkins.sh"