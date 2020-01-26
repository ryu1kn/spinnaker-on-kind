SHELL := /bin/bash

include config.mk

parent_dir = $(dir $(lastword $1))

include makefiles/manifest.mk
include makefiles/image.mk

$(shell mkdir -p $(work_dir))

.PHONY: all
all: create-cluster cache-images apply-manifest wait-for-deployment-complete expose-ui-port

.PHONY: create-cluster
create-cluster:
	test -z "$(docker ps --filter name=kind-control-plane -q)" && $(script_dir)/kind-with-registry.sh
	kind export kubeconfig

.PHONY: apply-manifest delete-manifest
apply-manifest delete-manifest: $(work_dir)/$(manifest)
	kubectl $(@:-manifest=) -f $<

.PHONY: wait-for-deployment-complete
wait-for-deployment-complete:
	until [[ "$$(kubectl get jobs $(helm_template_name)-install-using-hal -o jsonpath='{.status.succeeded}')" = 1 ]] ; do \
		echo "Waiting for the install job to complete..."; sleep 10; \
	done

.PHONY: expose-ui-port
expose-ui-port:
	kubectl port-forward svc/spin-deck $(spinnaker_ui_port):9000

.PHONY: clean
clean:
	rm -rf $(work_dir)
