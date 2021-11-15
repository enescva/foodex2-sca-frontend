 #!/bin/bash  

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
mkdir $HOME/images
docker save foodex2sca:front -o $HOME/images/foodex2sca-front.tar
#rsync -v $HOME/images/foodex2sca-front.tar remote:/home/ubuntu/foodex2sca-front.tar
.gitpod/scp.sh $HOME/images/foodex2sca-front.tar root@127.0.0.1:/home/foodex2sca-front.tar
.gitpod/ssh.sh "sudo k3s ctr images import /home/foodex2sca-front.tar"

# launch service
kubectl create -f ./manifests/deployment.local.yml
kubectl get pods
POD=$(kubectl get pods -o=name |  sed "s/^.\{4\}//" | grep ^o )
kubectl port-forward $POD 8081:8081 &
gp await-port 8081 && echo "k3s pod running..." && gp preview $(gp url 8081)