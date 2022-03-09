# Firewall

If you have any issues with the firewall blocking access from the ingress to the service, try the suggestion here:

https://github.com/k3s-io/k3s/issues/1646

`firewall-cmd --permanent --add-masquerade && firewall-cmd --reload`

