---
#
# .-'_.---._'-.
# ||####|(__)||   Protect your secrets, protect your business.
#   \\()|##//       Secure your sensitive data with Aegis.
#    \\ |#//                  <aegis.z2h.dev>
#     .\_/.
#

layout: default
keywords: Aegis, architecture, configuration, environment
title: Configuring Aegis
description: buttons, lever, knobs, nuts, and bolts…
micro_nav: false
page_nav:
  prev:
    content: <strong>Aegis</strong> Deep Dive
    url: '/docs/architecture'
  next:
    content: design decisions
    url: '/docs/philosophy'
---

## Introduction

**Aegis** system components can be configured using environment variables.

The following section contain a breakdown of all of these environment variables.

## Environment Variables

### SPIFFE_ENDPOINT_SOCKET

`SPIFFE_ENDPOINT_SOCKET` is required for **Aegis Sentinel** to talk to
**Aegis SPIRE**.

If not provided, a default value of `"unix:///spire-agent-socket/agent.sock"`
will be used.

### AEGIS_LOG_LEVEL

`AEGIS_LOG_LEVEL` determines the verbosity of the logs in **Aegis Safe**.

`1`: logs are off, `6`: highest verbosity. default: `3`

```text
Off = 1
Error = 2
Warn = 3
Info = 4
Debug = 5
Trace = 6
```

### AEGIS_WORKLOAD_SVID_PREFIX

Both **Aegis Safe** and **workloads** use this environment variable.

`AEGIS_WORKLOAD_SVID_PREFIX` is required for validation. If not provided,
it will default to: `"spiffe://aegis.z2h.dev/workload/"`

### AEGIS_SENTINEL_SVID_PREFIX

Both **Aegis Safe** and **Aegis Sentinel** use this environment variable.

`AEGIS_SENTINEL_SVID_PREFIX` is required for validation.

If not provided, it will default to:
`"spiffe://aegis.z2h.dev/workload/aegis-sentinel/ns/aegis-system/sa/aegis-sentinel/n/"`

### AEGIS_SAFE_SVID_PREFIX

Both **Aegis Sentinel**, **Aegis Safe**, and **workloads** use this environment
variable.

`AEGIS_SAFE_SVID_PREFIX` is required for validation.

If not provided, it will default to:
`"spiffe://aegis.z2h.dev/workload/aegis-safe/ns/aegis-system/sa/aegis-safe/n/"`

### AEGIS_SAFE_DATA_PATH

`AEGIS_SAFE_DATA_PATH` is where the encrypted secrets are stored.

If not given, defaults to `"/data"`.

### AEGIS_SAFE_AGE_KEY_PATH

`AEGIS_SAFE_AGE_KEY_PATH` is where **Aegis Safe** will fetch the `"key.txt"`
that contains the encryption keys.

If not given, it will default to `"/key/key.txt"`.

### AEGIS_SAFE_ENDPOINT_URL

`AEGIS_SAFE_ENDPOINT_URL` is the **REST API** endpoint that **Aegis Safe**
exposes from its `Service`.

If not provided, it will default to:
`"https://aegis-safe.aegis-system.svc.cluster.local:8443/"`.

### AEGIS_PROBE_LIVENESS_PORT

`AEGIS_PROBE_LIVENESS_PORT` is the port where the liveness probe
will serve.

Defaults to `:8081`.

### AEGIS_PROBE_READINESS_PORT

`AEGIS_PROBE_READINESS_PORT` is the port where the readiness probe
will serve.

Defaults to `:8082`.

### AEGIS_SAFE_SVID_RETRIEVAL_TIMEOUT

`AEGIS_SAFE_SVID_RETRIEVAL_TIMEOUT` is how long (*in milliseconds*) **Aegis Safe**
will wait for an *SPIRE X.509 SVID* bundle before giving up and crashing.

The default value is `30000` milliseconds.

### AEGIS_SAFE_TLS_PORT

`AEGIS_SAFE_TLS_PORT` is the port that Safe serves its API endpoints.

Defaults to `":8443"`.

### AEGIS_SAFE_SECRET_BUFFER_SIZE

`AEGIS_SAFE_SECRET_BUFFER_SIZE` is the amount of secret insertion operations
to be buffered until **Safe API** blocks and waits for the buffer to have an
empty slot.

If the environment variable is not set, this buffer size defaults to `10`.

### AEGIS_SAFE_BACKING_STORE_TYPE

`AEGIS_SAFE_BACKING_STORE_TYPE` is the type of the storage where the secrets
will be encrypted and persisted.

If not given, defaults to `"persistent"`.

Any value other than `"persistent"` will mean `"in-memory"`.

An `"in-memory"` backing store means **Aegis Safe** does not persist backups
of the secrets it created to disk. When that option is selected, you will
lose all of your secrets if **Aegis Safe** is evicted by the scheduler or
manually restarted by an operator.

### AEGIS_SIDECAR_POLL_INTERVAL

`AEGIS_SIDECAR_POLL_INTERVAL` is the interval (*in milliseconds*) 
that the sidecar polls **Aegis Safe** for new secrets. 

Defaults to `20000` milliseconds, if not provided.

### AEGIS_SIDECAR_MAX_POLL_INTERVAL

**Aegis Sidecar** has an **exponential backoff** algorithm to execute fetch
in longer intervals when an error occurs. `AEGIS_SIDECAR_MAX_POLL_INTERVAL`
is the maximum wait time (*in milliseconds*) before executing the next.

Defaults to `300000` milliseconds, if not provided.

### AEGIS_SIDECAR_EXPONENTIAL_BACKOFF_MULTIPLIER

`AEGIS_SIDECAR_EXPONENTIAL_BACKOFF_MULTIPLIER` configures how fast the algorithm
backs off when there is a failure. Defaults to `2`, which means when there are
enough failures to trigger a backoff, the next wait interval will be twice the
current one.

### AEGIS_SIDECAR_SUCCESS_THRESHOLD

`AEGIS_SIDECAR_SUCCESS_THRESHOLD` configures the number of successful poll 
results before reducing the poll interval. Defaults to `3`.

The next interval is calculated by dividing the current interval with
`AEGIS_SIDECAR_EXPONENTIAL_BACKOFF_MULTIPLIER`.

### AEGIS_SIDECAR_ERROR_THRESHOLD

`AEGIS_SIDECAR_ERROR_THRESHOLD` configures the number of fetch failures before
increasing the poll interval. Defaults to `2`.

The next interval is calculated by multiplying the current interval with
`AEGIS_SIDECAR_EXPONENTIAL_BACKOFF_MULTIPLIER`.