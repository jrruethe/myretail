# Getting started

> Make sure you don't have something already listening on ports 80/443

## Deploy k3s to get a Kubernetes Cluster

```
# In its own terminal window
./create_kubernetes_cluster.sh
```

## Deploy the hello-world application

```
# In a second terminal window
./deploy.sh
```

## Check the results in your browser

Go to `http://helloworld.localhost`

The hello-world application is using the `traefik/whoami` image from here:

https://github.com/traefik/whoami
