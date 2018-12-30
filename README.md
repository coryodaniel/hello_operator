# HelloOperator

Hello world operator created with Bonny.

[Bonny](https://github.com/coryodaniel/bonny) is a Kubernetes Operator SDK written in Elixir.

[HelloOperator Docker Image](https://quay.io/coryodaniel/hello_operator)

This [operator](./manifest.yaml) contains all the resources necessary to define an operator (CRDs, RBAC, ServiceAccount, and Deployment). The operator itself creates a simple Deployment running the [greeting-server](https://github.com/coryodaniel/greeting-server) and an HTTP Service.

The code for generating the lifecycle of a `Greeting` Deployment/Service is [here](./lib/hello_operator/controllers/v1/greeting.ex).

## Usage

*Deploying the operator:*

```shell
mix deps.get
mix compile

# Build docker image
mix bonny.gen.dockerfile
export BONNY_IMAGE=YOUR_IMAGE_NAME_HERE
docker build -t ${BONNY_IMAGE} .
docker push ${BONNY_IMAGE}:latest

# Optionally, skip building the docker image and play with the operator
# export BONNY_IMAGE=quay.io/coryodaniel/hello_operator

# Deploy to kubernetes
mix bonny.gen.manifest --image ${BONNY_IMAGE}
kubectl apply -f ./manifest.yaml
```

*Create two `Greeting` resources:*

Create the "Hello" and "Hola" Greeting services:

```shell
kubectl apply -f ./greetings.yaml
```

Inspect the greeting resources:

```shell
# you should see two greetings
kubectl get greetings 

kubectl describe greetings/hello-server

kubectl describe greetings/hola-server
```

You should be able to browse to NodePort Service of each:

```shell
kubectl get svc/hello-server
kubectl get svc/hola-server
```

* http://HELLO_SERVICE_NODE_PORT/greeting/Chauncy - Hello, Chauncy
* http://HOLA_SERVICE_NODE_PORT/greeting/Chauncy - Hola, Chauncy

## Kubernetes Client

This project uses a very trivial [kubernetes client](./lib/k8s/client.ex). It is not recommended for production.
