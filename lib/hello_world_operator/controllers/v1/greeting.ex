defmodule HelloWorldOperator.Controller.V1.Greeting do
  @moduledoc """
  HelloWorldOperator: Greeting CRD.

  ## Kubernetes CRD Spec

  By default all CRD specs are assumed from the module name, you can override them using attributes.

  ### Examples
  ```
  # Kubernetes API version of this CRD, defaults to value in module name
  @version "v2alpha1"

  # Kubernetes API group of this CRD, defaults to "bonny.example.io"
  @group "kewl.example.io"

  The scope of the CRD. Defaults to `:namespaced`
  @scope :cluster

  CRD names used by kubectl and the kubernetes API
  @names %{
    plural: "foos",
    singular: "foo",
    kind: "Foo"
  }
  ```

  ## Declare RBAC permissions used by this module

  RBAC rules can be declared using `@rule` attribute and generated using `mix bonny.manifest`

  This `@rule` attribute is cumulative, and can be declared once for each Kubernetes API Group.

  ### Examples

  ```
  @rule {apiGroup, resources_list, verbs_list}

  @rule {"", ["pods", "secrets"], ["*"]}
  @rule {"apiextensions.k8s.io", ["foo"], ["*"]}
  ```
  """
  use Bonny.Controller
  @rule {"apps", ["deployments"], ["*"]}
  @rule {"", ["services"], ["*"]}

  # @group "your-operator.your-domain.com"
  # @version "v1"
  # @scope :namespaced
  # @names %{
  #   plural: "foos",
  #   singular: "foo",
  #   kind: "Foo"
  # }

  # @rule {"", ["pods", "configmap"], ["*"]}
  # @rule {"", ["secrets"], ["create"]}

  @doc """
  Handles an `ADDED` event
  """
  @spec add(map()) :: :ok | :error
  def add(%{"metadata" => %{"name" => name}, "spec" => %{"greeting" => greeting}}) do
    add_deployment(name, greeting)
    add_service(name, greeting)
    :ok
  end

  defp add_service(name, greeting) do
    %{
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": %{
        "name": name,
        "labels": %{"app": "hello-server"}
      },
      "spec": %{
        "ports": [%{"port": 5000, "protocol": "TCP"}],
        "selector": %{"app": "hello-server"},
        "type": "NodePort"
      }
    }
  end

  defp add_deployment(name, greeting) do
    %{
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": %{
        "name": name,
        "labels": %{"app": "hello-server"}
      },
      "spec": %{
        "replicas": 2,
        "selector": %{
          "matchLabels": %{"app": "hello-server"}
        },
        "template": %{
          "metadata": %{
            "labels": %{"app": "hello-server"}
          },
          "spec": %{
            "containers": [
              %{
                "name": "hello-server",
                "image": "quay.io/coryodaniel/hello-world",
                "env": [%{"name": "GREETING", "value": greeting}],
                "ports": [%{"containerPort": 5000}]
              }
            ]
          }
        }
      }
    }
  end

  @doc """
  Handles a `MODIFIED` event
  """
  @spec add(map()) :: :ok | :error
  def modify(payload) do
    IO.inspect(payload)
    :ok
  end

  @doc """
  Handles a `DELETED` event
  """
  @spec add(map()) :: :ok | :error
  def delete(payload) do
    IO.inspect(payload)
    :ok
  end
end
