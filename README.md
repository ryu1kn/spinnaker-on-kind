
# Spinnaker on Kind

## Prerequisites

* `brew install kind helm yq`
* Have docker installed
* Have HELM stable repo added

    ```sh
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/
    ```

## Bring up Spinnaker

```sh
make start-cluster apply-manifest
```

## References

* [kind](https://kind.sigs.k8s.io/)
