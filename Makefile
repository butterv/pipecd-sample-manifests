install-sealed-secrets:
	kubectl apply -f k8s/manual/sealed-secrets/controller.yaml

dry-run:
	kustomize build k8s/ops/overlays/local/ | kubectl apply -f - --dry-run

run:
	kustomize build k8s/ops/overlays/local/ | kubectl apply -f -

stop:
	kubectl delete -k k8s/ops/overlays/local/
