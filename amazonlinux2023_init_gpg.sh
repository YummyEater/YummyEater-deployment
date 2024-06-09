###amazon linux 2023의 기본 패키지인 gnupg2-minimal에서 gpg-agent를 이용하기 위해 업그레이드
dnf install -y --allowerasing gnupg2-full


###gpg-agent 실행
eval $(gpg-agent --daemon)
