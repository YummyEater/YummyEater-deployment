###백엔드 환경변수를 Config Repository에서 clone
#GPG key를 gpg key ring에 등록
echo "$CONFIG_REPOSITORY_GITCRYPT_GPG_PRIVATEKEY" | gpg --import

#ssh key를 ssh-agent에 등록
echo "$CONFIG_REPOSITORY_SSH_PRIVATEKEY" | ssh-add -
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