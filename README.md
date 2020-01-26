
# Spinnaker on Kind

## Prerequisites

* Docker
* [Kind][1]: `brew install kind`
* kubectl: `brew install kubernetes-cli`

Unless you run `make` with `docker-compose run builder`, make sure you also have:

* [Helm][2]: `brew install helm`
* [jq][3]: `brew install jq`
* [yq][4]: `brew install python-yq` (Note: `brew install yq` installs a different package)

For details, check [`Dockerfile`](./Dockerfile).

## Usage

```sh
make all
```

This would take a while. After it's finished, open a browser and go to http://localhost:8080

**NOTE:** The `Dockerfile` still doesn't have all the necessary tools to run `make all`; so just run it on your host 😛

If you want to recreate your k8s cluster, you can always

```sh
kind delete cluster
```

## References

* [kind](https://kind.sigs.k8s.io/)

[1]: https://github.com/kubernetes-sigs/kind
[2]: https://github.com/helm/helm
[3]: https://stedolan.github.io/jq/manual/
[4]: https://kislyuk.github.io/yq/
