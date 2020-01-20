
# Spinnaker on Kind

## Prerequisites

* `brew install kind`
* Have docker installed

## Create Spinnaker settings

```sh
docker-compose run builder make build/manifest.yaml
```

## Bring up Spinnaker

```sh
make start-cluster apply-manifest
```

## References

* [kind](https://kind.sigs.k8s.io/)
