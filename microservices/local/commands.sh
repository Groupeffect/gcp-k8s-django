#!/bin/sh

start_minikube_podman(){
    # start minkube with rootles podman config
    minikube config set rootless true
    minikube start --driver=podman --container-runtime=cri-o
}
start_minikube_docker(){
    # start minkube with rootles podman config
    minikube config set rootless false
    minikube start
}
run_argocd(){
    kubectl create namespace argocd
    kubectl config set-context --current --namespace=argocd
    kubectl apply -n argocd -f ./argocd_install.yaml # adjust path if command is not finding the file
    # get password from cluster server shell to login in web ui: 
    # argocd admin initial-password -n argocd
    # argocd account update-password
}

port_forward_argocd(){
    kubectl port-forward svc/argocd-server -n argocd 8080:443
}
