# HelloWorldOperator

Hello world operator created with Bonny.

[Bonny](https://github.com/coryodaniel/bonny) is a Kubernetes Operator SDK written in Elixir.

[HelloWorld Operator Docker Image](https://quay.io/coryodaniel/hello_world_operator)

This [operator](./manifest.yaml) deploys a `Greeting` service which is a fancy k8s deployment running [this HelloWorld server](https://github.com/coryodaniel/hello-world) ([https://quay.io/coryodaniel/hello-world](Docker image)).

The code for generating the lifecycle of a `Greeting` service is [here](./lib/hello_world_operator/controllers/v1/greeting.ex).

## Usage

*Deploying the operator:*

```shell
mix deps.get
mix compile
mix bonny.gen.manifest --image quay.io/coryodaniel/hello_world_operator
kubectl apply -f ./manifest.yaml
```

*Deploying two `Greeting` services:*

"Hello" `Greeting` service:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: hello-world.bonny.test/v1
kind: Greeting
metadata:
  name: hello-greeting
spec:
  greeting: Hello
EOF
```

"Hola" `Greeting` service:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: hello-world.bonny.test/v1
kind: Greeting
metadata:
  name: hola-greeting
spec:
  greeting: Hola
EOF
```

Inspect the greeting resources:

```shell
# you should see two greetings
kubectl get greetings 

kubectl describe greetings/hello-greeting
```
