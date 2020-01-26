.PHONY: create-cluster
create-cluster:
	test -z "$(docker ps --filter name=kind-control-plane -q)" && $(script_dir)/kind-with-registry.sh
	kind export kubeconfig

.PHONY: delete-cluster
delete-cluster:
	kind delete cluster

.PHONY: delete-local-registry
delete-local-registry:
	docker stop $(local_registry_name) && docker rm $(local_registry_name)
