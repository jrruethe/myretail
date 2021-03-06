# Binary dependencies

This project deploys to a Kubernetes cluster using k3s:

https://github.com/k3s-io/k3s

To keep all dependencies bundled together with the project, the binary has been copied directly into this repo. You can verify the SHA256 hash against the one provided by the K3S developers to ensure the binary is the same:

`sha256sum -c k3s-sha256sum-amd64.txt`

Compare to the hash in [this](https://github.com/k3s-io/k3s/releases/download/v1.23.4%2Bk3s1/sha256sum-amd64.txt) file.
