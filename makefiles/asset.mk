
$(call generate_runner, $(spinnaker_ver_dir)/%)
$(spinnaker_ver_dir)/%:
	$(script_dir)/download-spinnaker-settings.sh $*
