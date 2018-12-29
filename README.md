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
mix bonny.gen.manifest --image quay.io/coryodaniel/hello_operator
kubectl apply -f ./manifest.yaml
```

*Create two `Greeting` resources:*

Create the "Hello" and "Hola" Greeting services:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: hello-operator.bonny.test/v1
kind: Greeting
metadata:
  name: hello-server
spec:
  greeting: Hello
---
apiVersion: hello-operator.bonny.test/v1
kind: Greeting
metadata:
  name: hola-server
spec:
  greeting: Hola
EOF
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
