#Jordan Knight (https://github.com/jakkaj)

. ./loadconfigs.sh

#prep the cluster configs 
cp ../kube/config.yaml ../kube/config.working.a.yaml
cp ../kube/config.yaml ../kube/config.working.b.yaml

declare storage=s-${a_rg:0:18}
storage="${storage,,}"
storage="${storage//-}"

cat >> ../kube/config.working.a.yaml << EOF
  storage: "$storage"
  a_resourceGroup: "$a_rg"
  b_resourceGroup: "$b_rg"
  this_cluster: "a"
  other_cluster: "b"
EOF

cat >> ../kube/config.working.b.yaml << EOF
  storage: "$storage"
  a_resourceGroup: "$a_rg"
  b_resourceGroup: "$b_rg"
  this_cluster: "b"
  other_cluster: "a"
EOF

echo "export KUBECONFIG=$PWD/../builds/$kubeconfig_acs_latest:$PWD/../builds/$kubeconfig_aks_latest" > ../builds/kubeconfig.sh

echo "Configuring clusters (istio etc)"
wait 2

export KUBECONFIG=$kubeconfig_aks
#install istio
kubectl create namespace istio-system
kubectl apply -f ../kube/istio.yaml
kubectl label namespace default istio-injection=enabled

kubectl apply -f ../kube/config.working.a.yaml

#install tiller
kubectl delete deployment tiller-deploy --namespace kube-system
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init  --upgrade --service-account tiller

istioctl create -f ../kube/istioctl.yaml



export KUBECONFIG=$kubeconfig_acs
#install istio
kubectl create namespace istio-system
kubectl apply -f ../kube/istio.yaml
kubectl label namespace default istio-injection=enabled

kubectl apply -f ../kube/config.working.b.yaml

#install tiller
kubectl delete deployment tiller-deploy --namespace kube-system
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init  --upgrade --service-account tiller


istioctl create -f ../kube/istioctl.yaml

echo "Configuring clusters done"