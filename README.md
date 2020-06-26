
# Spinnaker on Kind

Trying Spinnaker is sometimes not trivial. It can require lots of machine power
and many configurations.

With this repo, you can run Spinnaker of your version choice on your machine.
It uses [KIND (Kubernetes IN Docker)][1] cluster to host Spinnaker services;
so cleaning down after use is just as easy as deleting the cluster.

## Prerequisites

* Docker
* [Kind][1]: `brew install kind`
* kubectl: `brew install kubernetes-cli`

Unless you run `make` with `WITH_DOCKER=true`, make sure you also have:

* [Helm][2]: `brew install helm`
* [jq][3]: `brew install jq`
* [yq][4]: `brew install python-yq` (Note: `brew install yq` installs a different package)

For details, check [`Dockerfile`](./Dockerfile).

## Usage

```sh
export WITH_DOCKER=true
make all
```

This would take a while. After it's finished, open a browser and go to http://localhost:9000

**NOTE:** The `Dockerfile` still doesn't have all the necessary tools to run `make all`; so just run it on your host 😛

If you start all over again, you can do:

```sh
make teardown
```

## Running behind a corporate proxy

When running it behind a corporate proxy, be sure list the local docker registry
in `NO_PROXY` environment variable and export the variable before creating a Kind cluster.
See [this issue][5] for more detail.

## References

* [kind](https://kind.sigs.k8s.io/)

[1]: https://github.com/kubernetes-sigs/kind
[2]: https://github.com/helm/helm
[3]: https://stedolan.github.io/jq/manual/
[4]: https://kislyuk.github.io/yq/
[5]: https://github.com/kubernetes-sigs/kind/issues/1304
