
# Spinnaker on Kind

## Prerequisites

* `brew install kind`
* Have docker installed

## Start Kind with local docker registry

```sh
make start-cluster
```

If you want to recreate your k8s cluster, you can always

```sh
kind delete cluster
```

If you want to delete the local registry. To do so:

```sh
docker rm -f kind-registry
```

## Cache Spinnaker images to the local registry

Update images.txt file and:

```sh
make cache-images
```

## Create Spinnaker settings

```sh
docker-compose run builder make build/manifest.yaml
```

## Bring up Spinnaker

```sh
make apply-manifest
```

## Make Spinnaker Accessible

```sh
make expose-spin
```

Open a browser and go to http://localhost:8080

## References

* [kind](https://kind.sigs.k8s.io/)
