# kernel dev environment
sudo apt update -y
sudo apt install qemu qemu-system-x86 linux-image-$(uname -r) libguestfs-tools sshpass netcat -y
sudo curl -o /usr/bin/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x /usr/bin/kubectl
.gitpod/prepare-rootfs.sh && .gitpod/qemu.sh &
# prepare k3s
.gitpod/prepare-k3s.sh

# create docker image
docker build -t foodex2sca:front . 
docker save foodex2sca:front -o $HOME/images/foodex2sca-front.tar
#rsync -v $HOME/images/foodex2sca-front.tar remote:/home/ubuntu/foodex2sca-front.tar
#sudo k3s ctr images import /home/ubuntu/foodex2sca-front.tar

# launch service
k3d create -v $HOME/images:/var/lib/rancher/k3s/agent/images
kubectl create -f ./manifests/deployment.local.yml
