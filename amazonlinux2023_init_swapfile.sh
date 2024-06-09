###스왑메모리 설정
#/swapfile을 생성하고 128MB 블록 사이즈로 16개의 블록 즉 2GB를 할당
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