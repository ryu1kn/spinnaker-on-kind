
# Spinnaker on Kind

## Prerequisites

* Docker
* [Kind][1]: `brew install kind`

Unless you run `make` with `docker-compose run builder`, make sure you also have:

* [Helm][2]: `brew install helm`
* [jq][3]: `brew install jq`
* [yq][4]: `brew install python-yq` (Note: `brew install yq` installs a different package)

For details, check [Dockerfile](./Dockerfile).

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

```sh
make cache-images
```

## Create Spinnaker settings

```sh
make build/manifest.yaml
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

[1]: https://github.com/kubernetes-sigs/kind
[2]: https://github.com/helm/helm
[3]: https://stedolan.github.io/jq/manual/
[4]: https://kislyuk.github.io/yq/
