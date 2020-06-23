SHELL := /bin/bash

include config.mk

parent_dir = $(dir $(lastword $1))

ifeq ($(WITH_DOCKER), true)
generate_runner = $(eval $1: SHELL := docker-compose run builder bash -c)
endif

include makefiles/manifest.mk
include makefiles/image.mk
include makefiles/deployment.mk
include makefiles/cluster.mk

$(shell mkdir -p $(work_dir))

.PHONY: all
all: create-cluster cache-images apply-manifest wait-for-deployment-complete expose-spin-ports

.PHONY: teardown
teardown: clean delete-cluster delete-local-registry

.PHONY: clean
clean:
	rm -rf $(work_dir)
