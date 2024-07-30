#!/bin/sh

pushd ../

# Create httpbin namespace if it does not exist yet
kubectl create namespace httpbin --dry-run=client -o yaml | kubectl apply -f -

# Create portal-env namespace if it does not exist yet
kubectl create namespace portal-env --dry-run=client -o yaml | kubectl apply -f -

printf "\nInstalling K8S Services & Deployments ...\n"
kubectl apply -f apis/httpbin.yaml
kubectl apply -f apis/petstore.yaml
printf "\n"

printf "\nInstalling APIDocs ...\n"
kubectl apply -f apis/httpbin-schema-apidoc.yaml
kubectl apply -f apis/petstore-schema-apidoc.yaml
printf "\n"

printf "\nInstalling API Products ...\n"
kubectl apply -f apis/httpbin-product-apiproduct.yaml
kubectl apply -f apis/petstore-product-apiproduct.yaml
printf "\n"

printf "\nInstalling Portal Environment ...\n"
kubectl apply -f environment/dev-environment.yaml
printf "\n"

printf "\nInstalling Users and Groups ...\n"
kubectl apply -f users-groups/developers-group-users-secret.yaml
printf "\n"

printf "\nInstalling Portal ...\n"
kubectl apply -f portal/petstore-portal-portal.yaml
printf "\n"
 
popd