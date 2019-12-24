manifest := manifest.yaml
jar_patch_dir := workdir
cache_image_file := images.txt
spinnaker_helm_ver := 1.22.4

recreate_dir = rm -rf "$1" && mkdir "$1"

$(manifest): helm-values.yaml
	helm template my stable/spinnaker --version $(spinnaker_helm_ver) \
		--set "custom.foo=bar" \
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
