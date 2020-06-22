
registry_port := 5000
spinnaker_helm_ver := 2.0.0-rc8
spinnaker_ver := 1.20.5
spinnaker_halyard_ver := 1.36.0
spinnaker_docker_repository := gcr.io/spinnaker-marketplace
helm_template_name := my
helm_chart_repository := https://kubernetes-charts.storage.googleapis.com
local_registry_name := kind-registry
spinnaker_ui_port := 8080

manifest := manifest.yaml
spinnaker_ver_dir := __spinnaker-versions
spinnaker_settings_dir := __bom
script_dir := ./scripts
work_dir := ./build
custom_config := config-override.mk

ifneq ($(wildcard $(custom_config)),)
include $(custom_config)
endif

# Use `make print-var_name` to get the value of variable `var_name`
print-%:
	@echo '$($*)'
