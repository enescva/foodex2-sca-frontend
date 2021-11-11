docker build -t foodex2sca:front . 
kubectl create -f ./manifests/deployment.local.yml
