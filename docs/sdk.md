---
#
# .-'_.---._'-.
# ||####|(__)||   Protect your secrets, protect your business.
#   \\()|##//       Secure your sensitive data with Aegis.
#    \\ |#//                    <aegis.ist>
#     .\_/.
#

layout: default
keywords: Aegis, installation, deployment, faq, quickstart
title: Using Aegis Go SDK
description: directly consume the <strong>Aegis Safe</strong> API
micro_nav: true
page_nav:
  prev:
    content: local development
    url: '/docs/contributing'
  next:
    content: <strong>Aegis</strong> Sentinel CLI
    url: '/docs/sentinel'
---

This is the documentation for [Aegis Go SDK][go-sdk].

[go-sdk]: https://github.com/zerotohero-dev/aegis-sdk-go


## Package `sentry`

The current SDK has two public methods under the package `sentry`:

* `func Fetch`
* `func Watch`

### `func Fetch() (string, error)`

`Fetch` fetches the up-to-date secret that has been registered to the workload.

```go
secret, err := sentry.Fetch()
```

In case of a problem, `Fetch` will return an empty string and an error 
explaining what went wrong.


### `func Watch()`

`Watch` synchronizes the internal state of the workload by talking to 
[**Aegis Safe**][aegis-safe] regularly. It periodically calls `Fetch()` 
behind the scenes to get its work done. Once it fetches the secrets, 
it saves them to the location defined in the `AEGIS_SIDECAR_SECRETS_PATH` 
environment variable (*`/opt/aegis/secrets.json` by default*).

[aegis-safe]: https://github.com/zerotohero-dev/aegis-safe

## Usage Example

Here is a demo workload that uses the `Fetch()` API to retrieve secrets from 
**Aegis Safe**.

```go
package main

import (
	"fmt"
	"github.com/zerotohero-dev/aegis-sdk-go/sentry"
	"time"
)

func main() {
	for {
		// Fetch the secret bound to this workload
		// using Aegis Go SDK:
		data, err := sentry.Fetch()

		if err != nil {
			fmt.Println("Failed. Will retry…")
		} else {
			fmt.Println("secret: '", data, "'")
		}

		time.Sleep(5 * time.Second)
	}
}
```

Here follows a possible Deployment descriptor for such a workload. 

Check out [Aegis demo workload manifests][demos] for additional examples.

[demos]: https://github.com/zerotohero-dev/aegis/tree/main/install/k8s/demo-workload "Demo Workloads"

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aegis-workload-demo
  namespace: default
automountServiceAccountToken: false
---
apiVersion: spire.spiffe.io/v1alpha1
kind: ClusterSPIFFEID
metadata:
  name: aegis-workload-demo
spec:
  spiffeIDTemplate: "spiffe://aegis.ist/workload/aegis-workload-demo"
  podSelector:
    matchLabels:
      app.kubernetes.io/name: aegis-workload-demo
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aegis-workload-demo
  namespace: default
  labels:
    app.kubernetes.io/name: aegis-workload-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: aegis-workload-demo
  template:
    metadata:
      labels:
        app.kubernetes.io/name: aegis-workload-demo
    spec:
      serviceAccountName: aegis-workload-demo
      containers:
        - name: main
          image: z2hdev/aegis-workload-demo-using-sdk:0.7.0
          volumeMounts:
          - name: spire-agent-socket
            mountPath: /spire-agent-socket
            readOnly: true
          env:
          - name: SPIFFE_ENDPOINT_SOCKET
            value: unix:///spire-agent-socket/agent.sock
      volumes:
      - name: spire-agent-socket
        hostPath:
          path: /run/spire/sockets
          type: Directory
```

You can also [check out the relevant sections of the 
**Registering Secrets** article][registering-secrets] for an example of 
**Aegis Go SDK** usage.

[registering-secrets]: /docs/register

