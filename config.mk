
registry_port := 5000
spinnaker_helm_ver := 1.23.1
spinnaker_ver := 1.16.1
helm_template_name := my
remote_docker_registry := gcr.io/spinnaker-marketplace
local_registry_name := kind-registry
spinnaker_ui_port := 8080

manifest := manifest.yaml
spinnaker_ver_dir := __spinnaker-versions
spinnaker_settings_dir := __bom
script_dir := ./scripts
work_dir := ./build

# Use `make echo-var_name` to get the value of variable `var_name`
echo-%:
	@echo '$($*)'
