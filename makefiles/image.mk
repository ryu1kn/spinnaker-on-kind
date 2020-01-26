include $(call parent_dir,$(MAKEFILE_LIST))/asset.mk

.PHONY: cache-images
cache-images: $(work_dir)/$(spinnaker_ver)-images.txt
	$(script_dir)/cache-images.sh $<

$(work_dir)/%-images.txt: $(spinnaker_ver_dir)/%
	$(script_dir)/list-spinnaker-images.sh $</bom/$*.yml > $@
