SHELL := /bin/bash

manifest := manifest.yaml
cache_image_file := images.txt
spinnaker_helm_ver := 1.23.1
spinnaker_ver_dir := __spinnaker-versions
spinnaker_ver := 1.16.1
spinnaker_settings_dir := __bom
script_dir := ./scripts
work_dir := ./build

read_config = $(shell source config.sh && echo $$$1)
recreate_dir = rm -rf "$1" && mkdir "$1"
update_with = $1 < $2 > __tmp_file && mv -f __tmp_file $2 && rm -f __tmp_file
untar = mkdir -p $(1:.tar.gz=) && tar xvf $1 -C $(1:.tar.gz=) && rm -f $1

$(shell mkdir -p $(work_dir))

$(spinnaker_ver_dir)/%:
	$(script_dir)/download-spinnaker-settings.sh $*

$(work_dir)/spinnaker-$(spinnaker_helm_ver).tgz:
	helm pull stable/spinnaker --version $(spinnaker_helm_ver) --destination $(work_dir)

$(work_dir)/$(spinnaker_settings_dir): $(spinnaker_ver_dir)/$(spinnaker_ver)
	cp -r $< $@
	$(call update_with,$(script_dir)/localise-bom.sh,$@/bom/$(spinnaker_ver).yml)
	$(call untar,$@/rosco/packer.tar.gz)

$(work_dir)/bom.tgz: $(work_dir)/$(spinnaker_settings_dir)
	tar zcvf $@ -C $< .

$(work_dir)/$(manifest): helm-values.yaml $(work_dir)/bom.tgz $(work_dir)/spinnaker-$(spinnaker_helm_ver).tgz
	helm template my $(word 3,$^) \
		--set "custom.base64_bom_dir=$$(base64 $(word 2,$^))" \
		--set "halyard.image.repository=registry:$(call read_config,registry_port)/halyard" \
		--set "halyard.spinnakerVersion=$(spinnaker_ver)" \
		--values $< \
		| sed 's|apps/v1beta2|apps/v1|g' \
		> $@

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

.PHONY: expose-spin
expose-spin:
	kubectl port-forward svc/spin-deck 8080:9000

.PHONY: clean
clean:
	rm -rf $(work_dir)
