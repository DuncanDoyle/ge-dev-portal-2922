# Gloo Edge Portal - Missing Usage Plan

## Installation

Add Gloo EE and the Gloo Portal Helm repos:
```
helm repo add glooe https://storage.googleapis.com/gloo-ee-helm
helm repo add gloo-portal https://storage.googleapis.com/dev-portal-helm
```

Export your Gloo Edge License Key to an environment variable:
```
export GLOO_EDGE_LICENSE_KEY={your license key}
```

Install Gloo Edge:
```
cd install
./install-gloo-edge-enterprise-portal-with-helm.sh
```

> NOTE
> The Gloo Edge and Gloo Portal versions that will be installed are set in a variable at the top of the `install/install-gloo-edge-enterprise-portal-with-helm.sh` installation script.

## Setup the environment

Run the `install/setup.sh` script to setup the environment:

- Deploy the HTTPBin service (this service is simply used as a dummy backend for the APIProduct)
- Deploy the Petstore service
- Deploy the HTTPBin and Petstore APIDocs
- Deploy the HTTPBin and Petstore APIProducts
- Deploy the Environment
- Deploy the Portal

```
./setup.sh
```

## Reproducer

The `setup.sh` script has setup the environment with 2 ApiProduct: HTTPBin and Petstore. The Portal can be accessed at http://petstore.example.com and these two ApiProducts will be shown in the Developer Portal UI.

The HTTPBin ApiProduct uses 3 usage-plans: basic, gold an ultimate. The Petstore ApiProduct uses 2 usage-plans: basic and gold. These 3 usage-plans are configurd in the Environments CR `environment/dev-environment.yaml`.

When we now delete the "ultimate" usage-plan from the `environment/dev-environment.yaml` file and redeploy the environment CR
```
kubectl apply -f environment/dev-environment-without-ultimate-plan.yaml
```

... the environment CR will show the following warning in its status:

```
status:
  modifiedDate: "2024-07-30T09:47:12.628345209Z"
  observedGeneration: 3
  reason: 'invalid usage plans in API Product spec: usage plan [ultimate] not defined
    in environment'
  state: Invalid
```

At the same time, ALL the ApiProducts are removed from the Portal, not just the ApiProduct that is referencing a non-existing usage-plan. I.e. in our case, both the HTTPBin ApiProduct and Petstore ApiProduct are removed from the Portal, where only the HTTPBin ApiProduct is misconfigured.


# Conclusion
In the situation described in this issue, we would expect that only the misconfigured ApiProduct would be removed from the Portal, and all other ApiProducts would stay accessible. The main problem here is that the responsibility for these different CRs can lie with different teams, where the Platform team is responsible for the `Environment` CR and thus the usage-plan definitions, and the Product teams are responsible for the `ApiProduct` CRs which reference the usage-plan definitions. Say that you have 100 different ApiProducts on your Portal. With the current semantics, a Product team that misconfigures their `ApiProduct` CR and references a non-existing usage-plan (this can even be a simple typo) can bring down an entire Portal environment.

In this scenario we would expect that only the misconfigured ApiProduct is removed from the Portal environment, and all other ApiProducts remain accessible.