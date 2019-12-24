manifest := manifest.yaml
jar_patch_dir := workdir
cache_image_file := images.txt
spinnaker_helm_ver := 1.22.4
spinnaker_ver_dir := __spinnaker-versions
spinnaker_ver := 1.16.1
spinnaker_settings_dir := __bom

recreate_dir = rm -rf "$1" && mkdir "$1"
update_file = $1 < $2 > __tmp_file && mv -f __tmp_file $2 && rm -f __tmp_file

spinnaker-$(spinnaker_helm_ver).tgz:
	helm pull stable/spinnaker --version $(spinnaker_helm_ver)

$(spinnaker_settings_dir): $(spinnaker_ver_dir)/$(spinnaker_ver)
	cp -r $< $@
	$(call update_file,./localise-bom.sh,$@/bom/$(spinnaker_ver).yml)

bom.tgz: $(spinnaker_settings_dir)
	tar zcvf $@ -C $< .

$(manifest): helm-values.yaml bom.tgz spinnaker-$(spinnaker_helm_ver).tgz
	helm template my spinnaker-$(spinnaker_helm_ver).tgz \
		--set "custom.base64_bom_dir=$$(base64 -i bom.tgz)" \
		--values $< \
		| sed 's|apps/v1beta2|apps/v1|g' \
		> $@

.PHONY: start-cluster
start-cluster:
	test -z "$(docker ps --filter name=kind-control-plane -q)" && ./kind-with-registry.sh
	kind export kubeconfig

.PHONY: %-manifest
%-manifest: $(manifest)
	kubectl $* -f $(manifest)

.PHONY: cache-images
cache-images: $(cache_image_file)
	./cache-images.sh $<

halyard-deploy-original.jar: $(cache_image_file)
	hal_image=$$(fgrep /halyard: $< | sed 's|.*/||') \
		&& docker run --rm -v "$$(pwd):/copy" localhost:5000/$$hal_image bash -c '\
			cp /opt/halyard/lib/halyard-deploy-*.jar /copy/$@'

halyard-deploy-patched.jar: halyard-deploy-original.jar
	$(call recreate_dir,$(jar_patch_dir))
	mv $< $(jar_patch_dir)
	(cd $(jar_patch_dir) && unzip -q $< && rm -f $<)
	fgrep -l v1beta2 -R $(jar_patch_dir) | xargs sed -i '' 's/v1beta2/v1/'
	(cd $(jar_patch_dir) && zip -q -r9 ../$@ *)

Dockerfile-halyard-patch: $(cache_image_file) halyard-deploy-patched.jar
	hal_image=$$(fgrep /halyard: $< | sed 's|.*/||') \
	&& jar_path=$$(docker run --rm localhost:5000/$$hal_image bash -c 'ls /opt/halyard/lib/halyard-deploy-*.jar') \
		&& ./create-dockerfile-halyard.sh "$$hal_image" "$(word 2,$^)" "$$jar_path" > $@

.PHONY: patch-halyard
patch-halyard: $(cache_image_file) Dockerfile-halyard-patch
	hal_image=$$(fgrep /halyard: $< | sed 's|.*/||') \
		&& hal_image_reg="localhost:5000/$${hal_image}-patched" \
		&& docker build -t $$hal_image_reg -f $(word 2,$^) . \
		&& docker push $$hal_image_reg

.PHONY: expose-deck
expose-deck:
	kubectl expose deployment spin-deck --type=NodePort --name=spin-deck-2

.PHONY: clean
clean:
	rm -rf Dockerfile-halyard-patch $(manifest) spinnaker-$(spinnaker_helm_ver).tgz halyard-deploy-patched.jar $(jar_patch_dir)
