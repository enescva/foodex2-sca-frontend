# kernel dev environment
sudo apt update -y
sudo apt install qemu qemu-system-x86 linux-image-$(uname -r) libguestfs-tools sshpass netcat -y
sudo curl -o /usr/bin/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x /usr/bin/kubectl
.gitpod/prepare-rootfs.sh && .gitpod/qemu.sh &
# prepare k3s
.gitpod/prepare-k3s.sh

# create docker image
docker build -t foodex2sca_front . 
docker save foodex2sca_front -o $HOME/images/foodex2sca_front.tar
rsync -v foodex2sca_front.tar remote:/home/ubuntu/foodex2sca_front.tar

# launch service
k3d create -v $HOME/images:/var/lib/rancher/k3s/agent/images
kubectl create -f ./manifests/deployment.local.yml
