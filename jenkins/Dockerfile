# host의 docker socket과 cli를 공유하는 방식으로 docker를 설치하지 않는다
# git-crypt와 openssl을 설치하고 github를 known host로 등록한다


# Jenkins 공식 이미지를 베이스로 사용
FROM jenkins/jenkins:lts

# 루트 사용자로 변경
USER root

###openssl 1.1.1 빌드 및 설치(git-crypt와 openssl3.0이 호환되지 않음)
#docker의 cache때문에 apt-get update와 다운로드 코드를 같이 뒀다. 필요 패키지 설치.
RUN apt-get update && apt-get install -y g++ make perl
#소스 코드를 다운로드
RUN curl -LO https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
#압축 해제
RUN tar -zxvf openssl-1.1.1w.tar.gz
#설치
RUN cd openssl-1.1.1w && ./config && make && make install
#ld.so.conf.d에 추가하고 ld.so.cache를 업데이트
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openssl.conf && ldconfig

# git-crypt 설치
#실행 바이너리를 다운로드
RUN curl -LO https://github.com/AGWA/git-crypt/releases/download/0.7.0/git-crypt-0.7.0-linux-x86_64
#실행 권한 부여
RUN chmod +x git-crypt-0.7.0-linux-x86_64
#모든 사용자가 이용 가능하도록 전역 디렉터리로 이동
RUN mv git-crypt-0.7.0-linux-x86_64 /usr/local/bin/git-crypt

# github를 known host에 등록
RUN mkdir -p ~/.ssh
RUN ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

###dos2unix, aws cli 설치. 그리고 패키지 파일과 패키지 목록 캐시를 제거해서 이미지 크기를 줄임
RUN apt-get update && \
    apt-get install -y dos2unix awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 초기화 스크립트 복사
COPY ./init.sh /init.sh
RUN dos2unix /init.sh
RUN chmod +x /init.sh
# 초기화 후 jenkins 사용자로 jenkins 서버 실행
ENTRYPOINT ["/usr/bin/tini","--","/init.sh"]