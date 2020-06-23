.PHONY: apply-manifest delete-manifest
apply-manifest delete-manifest: $(work_dir)/$(manifest)
	kubectl $(@:-manifest=) -f $<

.PHONY: wait-for-deployment-complete
wait-for-deployment-complete:
	until [[ "$$(kubectl get jobs $(helm_template_name)-install-using-hal -o jsonpath='{.status.succeeded}')" = 1 ]] ; do \
		echo "Waiting for the install job to complete..."; sleep 10; \
	done

.PHONY: expose-spin-ports
expose-spin-ports:
	kubectl port-forward svc/spin-deck $(spinnaker_ui_port):9000 &
	kubectl port-forward svc/spin-gate $(spinnaker_api_port):8084 &
