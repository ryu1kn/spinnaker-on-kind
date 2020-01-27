is_inside_docker := $(shell [[ -f /proc/1/cgroup ]] && fgrep -m 1 docker /proc/1/cgroup)

ifdef is_inside_docker
KUBECTL_OPT := --kubeconfig <(sed 's/127\.0\.0\.1/host.docker.internal/g' ~/.kube/config) --insecure-skip-tls-verify
endif

KUBECTL := kubectl $(KUBECTL_OPT)

.PHONY: apply-manifest delete-manifest
apply-manifest delete-manifest: $(work_dir)/$(manifest)
	$(KUBECTL) $(@:-manifest=) -f $<

.PHONY: wait-for-deployment-complete
wait-for-deployment-complete:
	until [[ "$$($(KUBECTL) get jobs $(helm_template_name)-install-using-hal -o jsonpath='{.status.succeeded}')" = 1 ]] ; do \
		echo "Waiting for the install job to complete..."; sleep 10; \
	done

.PHONY: expose-ui-port
expose-ui-port:
	$(KUBECTL) port-forward svc/spin-deck $(spinnaker_ui_port):9000
