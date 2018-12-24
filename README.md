# HelloWorldOperator

Hello world operator created with Bonny.

[Bonny](https://github.com/coryodaniel/bonny) is a Kubernetes Operator SDK written in Elixir.

[HelloWorld Operator Docker Image](https://quay.io/coryodaniel/hello_world_operator)

[HelloWorld Server Docker Image](https://quay.io/coryodaniel/hello-world)

## Usage

*Deploying the operator:*

```shell
mix deps.get
mix compile
mix bonny.gen.manifest --image quay.io/coryodaniel/hello_world_operator
kubectl apply -f ./manifest.yaml
```

*Deploying a HelloWorld servers:*

"Hello" server:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: bonny.test/v1
kind: Greeting
metadata:
  name: hello-greeting
spec:
  greeting: Hello
EOF
```

"Hola" server:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: bonny.test/v1
kind: Greeting
metadata:
  name: hola-greeting
spec:
  greeting: Hola
EOF
```
