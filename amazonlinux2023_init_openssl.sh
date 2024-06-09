yum install -y gcc-c++ make perl

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
