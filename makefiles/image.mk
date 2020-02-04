include $(call parent_dir,$(MAKEFILE_LIST))/asset.mk

.PHONY: cache-images
cache-images: $(work_dir)/$(spinnaker_ver)-images.txt
	$(script_dir)/cache-images.sh $<

$(call generate_runner, $(work_dir)/%-images.txt)
$(work_dir)/%-images.txt: $(spinnaker_ver_dir)/%
	echo "$(remote_docker_registry)/halyard:$(spinnaker_halyard_ver)" > $@
	$(script_dir)/list-spinnaker-images.sh $</bom/$*.yml >> $@
