include $(call parent_dir,$(MAKEFILE_LIST))/asset.mk

recreate_dir = rm -rf "$1" && mkdir "$1"
update_with = $1 < $2 > __tmp_file && mv -f __tmp_file $2 && rm -f __tmp_file
untar = mkdir -p $(1:.tar.gz=) && tar xvf $1 -C $(1:.tar.gz=) && rm -f $1

$(call generate_runner, $(work_dir)/$(manifest))
$(work_dir)/$(manifest): helm-values.yaml $(work_dir)/bom.tgz $(work_dir)/spinnaker-$(spinnaker_helm_ver).tgz
	helm template $(helm_template_name) $(word 3,$^) \
		--set "custom.base64_bom_dir=$$(base64 $(word 2,$^))" \
		--set "halyard.image.repository=localhost:$(registry_port)/halyard" \
		--set "halyard.image.tag=$(spinnaker_halyard_ver)" \
		--set "halyard.spinnakerVersion=$(spinnaker_ver)" \
		--values $< \
		| sed 's|apps/v1beta2|apps/v1|g' \
		> $@

$(work_dir)/bom.tgz: $(work_dir)/$(spinnaker_settings_dir)
	tar zcvf $@ -C $< .

$(call generate_runner, $(work_dir)/$(spinnaker_settings_dir))
$(work_dir)/$(spinnaker_settings_dir): $(spinnaker_ver_dir)/$(spinnaker_ver)
	rm -rf $@
	cp -r $< $@
	$(call update_with,$(script_dir)/localise-bom.sh,$@/bom/$(spinnaker_ver).yml)
	$(call untar,$@/rosco/packer.tar.gz)

$(call generate_runner, $(work_dir)/spinnaker-$(spinnaker_helm_ver).tgz)
$(work_dir)/spinnaker-$(spinnaker_helm_ver).tgz:
	helm pull $(helm_chart_repository)/spinnaker-$(spinnaker_helm_ver).tgz --destination $(work_dir)
