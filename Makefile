SHELL := /bin/bash

include config.mk

recreate_dir = rm -rf "$1" && mkdir "$1"
update_with = $1 < $2 > __tmp_file && mv -f __tmp_file $2 && rm -f __tmp_file
untar = mkdir -p $(1:.tar.gz=) && tar xvf $1 -C $(1:.tar.gz=) && rm -f $1

$(shell mkdir -p $(work_dir))

.PHONY: start-cluster
start-cluster:
	test -z "$(docker ps --filter name=kind-control-plane -q)" && $(script_dir)/kind-with-registry.sh
	kind export kubeconfig

.PHONY: apply-manifest delete-manifest
apply-manifest delete-manifest: $(work_dir)/$(manifest)
	kubectl $(@:-manifest=) -f $<

.PHONY: cache-images
cache-images: $(cache_image_file)
	$(script_dir)/cache-images.sh $<

$(work_dir)/images-$(spinnaker_ver).txt: $(spinnaker_ver_dir)/$(spinnaker_ver)
	$(script_dir)/jq-y.sh '.services | to_entries | map(select(.value.version != null) | "$(remote_docker_registry)/\(.key):\(.value.version)")' \
		$</bom/$(spinnaker_ver).yml \
		| cut -c3- > $@

.PHONY: expose-spin
expose-spin:
	kubectl port-forward svc/spin-deck 8080:9000

.PHONY: clean
clean:
	rm -rf $(work_dir)

$(work_dir)/$(manifest): helm-values.yaml $(work_dir)/bom.tgz $(work_dir)/spinnaker-$(spinnaker_helm_ver).tgz
	helm template my $(word 3,$^) \
		--set "custom.base64_bom_dir=$$(base64 $(word 2,$^))" \
		--set "halyard.image.repository=registry:$(registry_port)/halyard" \
		--set "halyard.spinnakerVersion=$(spinnaker_ver)" \
		--values $< \
		| sed 's|apps/v1beta2|apps/v1|g' \
		> $@

$(work_dir)/bom.tgz: $(work_dir)/$(spinnaker_settings_dir)
	tar zcvf $@ -C $< .

$(work_dir)/$(spinnaker_settings_dir): $(spinnaker_ver_dir)/$(spinnaker_ver)
	rm -rf $@
	cp -r $< $@
	$(call update_with,$(script_dir)/localise-bom.sh,$@/bom/$(spinnaker_ver).yml)
	$(call untar,$@/rosco/packer.tar.gz)

$(work_dir)/spinnaker-$(spinnaker_helm_ver).tgz:
	helm pull stable/spinnaker --version $(spinnaker_helm_ver) --destination $(work_dir)

$(spinnaker_ver_dir)/%:
	$(script_dir)/download-spinnaker-settings.sh $*
