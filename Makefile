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
