install-argo-cd:
	kubectl create namespace argocd
	kubectl apply -n argocd -f k8s/manual/argo-cd/install.sh

install-argo-rollouts:
	kubectl create namespace argo-rollouts
	kubectl apply -n argo-rollouts -f k8s/manual/argo-rollouts/install.sh

install-sealed-secrets:
	kubectl apply -f k8s/manual/sealed-secrets/controller.sh

dry-run:
	kustomize build k8s/ops/overlays/local/ | kubectl apply -f - --dry-run

run:
	kustomize build k8s/ops/overlays/local/ | kubectl apply -f -

stop:
	kubectl delete -k k8s/ops/overlays/local/

rollout-proxy-watch:
	kubectl argo rollouts get rollout secret-sample-proxy -w

rollout-server-watch:
	kubectl argo rollouts get rollout secret-sample-server -w
