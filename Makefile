manifest := manifest.yaml
cache_image_file := images.txt
spinnaker_helm_ver := 1.22.4
spinnaker_ver_dir := __spinnaker-versions
spinnaker_ver := 1.16.1
spinnaker_settings_dir := __bom
script_dir := ./scripts
work_dir := ./build
jar_patch_dir = $(work_dir)/jar_patch_work

recreate_dir = rm -rf "$1" && mkdir "$1"
update_with = $1 < $2 > __tmp_file && mv -f __tmp_file $2 && rm -f __tmp_file
untar = tar zxvf $1 -C $(dir $1) && rm -f $1

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
		--set "custom.base64_bom_dir=$$(base64 -i $(word 2,$^))" \
		--values $< \
		| sed 's|apps/v1beta2|apps/v1|g' \
		> $@

.PHONY: start-cluster
start-cluster:
	test -z "$(docker ps --filter name=kind-control-plane -q)" && $(script_dir)/kind-with-registry.sh
	kind export kubeconfig

.PHONY: %-manifest
%-manifest: $(work_dir)/$(manifest)
	kubectl $* -f $<

.PHONY: cache-images
cache-images: $(cache_image_file)
	$(script_dir)/cache-images.sh $<

$(work_dir)/halyard-deploy-original.jar: $(cache_image_file)
	hal_image=$$(fgrep /halyard: $< | sed 's|.*/||') \
		&& docker run --rm -v "$$(pwd)/$(dir $@):/copy" localhost:5000/$$hal_image bash -c '\
			cp /opt/halyard/lib/halyard-deploy-*.jar /copy/$(notdir $@)'

$(work_dir)/halyard-deploy-patched.jar: $(work_dir)/halyard-deploy-original.jar
	$(call recreate_dir,$(jar_patch_dir))
	mv $< $(jar_patch_dir)
	(cd $(jar_patch_dir) && unzip -q $(notdir $<) && rm -f $(notdir $<))
	fgrep -l v1beta2 -R $(jar_patch_dir) | xargs sed -i '' 's/v1beta2/v1/'
	(cd $(jar_patch_dir) && zip -q -r9 ../$(notdir $@) *)

$(work_dir)/Dockerfile-halyard-patch: $(cache_image_file) $(work_dir)/halyard-deploy-patched.jar
	hal_image=$$(fgrep /halyard: $< | sed 's|.*/||') \
	&& jar_path=$$(docker run --rm localhost:5000/$$hal_image bash -c 'ls /opt/halyard/lib/halyard-deploy-*.jar') \
		&& $(script_dir)/create-dockerfile-halyard.sh "$$hal_image" "$(word 2,$^)" "$$jar_path" > $@

.PHONY: patch-halyard
patch-halyard: $(cache_image_file) $(work_dir)/Dockerfile-halyard-patch
	hal_image=$$(fgrep /halyard: $< | sed 's|.*/||') \
		&& hal_image_reg="localhost:5000/$${hal_image}-patched" \
		&& docker build -t $$hal_image_reg -f $(word 2,$^) . \
		&& docker push $$hal_image_reg

.PHONY: expose-deck
expose-deck:
	kubectl expose deployment spin-deck --type=NodePort --name=spin-deck-2

.PHONY: clean
clean:
	rm -rf $(work_dir)
