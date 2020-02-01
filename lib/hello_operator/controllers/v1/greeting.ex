defmodule HelloOperator.Controller.V1.Greeting do
  @moduledoc """
  HelloOperator: Greeting CRD.

  ## Kubernetes CRD Spec

  By default all CRD specs are assumed from the module name, you can override them using attributes.

  ### Examples
  ```
  # Kubernetes API version of this CRD, defaults to value in module name
  @version "v2alpha1"

  # Kubernetes API group of this CRD, defaults to "hello-operator.example.com"
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
  require Logger
  use Bonny.Controller
  @rule {"apps", ["deployments"], ["*"]}
  @rule {"", ["services"], ["*"]}

  # @group "your-operator.your-domain.com"
  # @version "v1"
  @scope :namespaced
  @names %{
    plural: "greetings",
    singular: "greeting",
    kind: "Greeting"
  }

  @doc """
  Called periodically for each existing CustomResource to allow for reconciliation.
  """
  @spec reconcile(map()) :: :ok | :error
  @impl Bonny.Controller
  def reconcile(payload) do
    track_event(:reconcile, payload)
    :ok
  end

  @doc """
  Creates a kubernetes `deployment` and `service` that runs a "Hello, World" app.
  """
  @spec add(map()) :: :ok | :error
  @impl Bonny.Controller
  def add(payload) do
    track_event(:add, payload)
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.create(resources.deployment) |> run,
         {:ok, _} <- K8s.Client.create(resources.service) |> run do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Updates `deployment` and `service` resources.
  """
  @spec modify(map()) :: :ok | :error
  @impl Bonny.Controller
  def modify(payload) do
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.patch(resources.deployment) |> run,
         {:ok, _} <- K8s.Client.patch(resources.service) |> run do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Deletes `deployment` and `service` resources.
  """
  @spec delete(map()) :: :ok | :error
  @impl Bonny.Controller
  def delete(payload) do
    track_event(:delete, payload)
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.delete(resources.deployment) |> run,
         {:ok, _} <- K8s.Client.delete(resources.service) |> run do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  defp parse(%{
         "metadata" => %{"name" => name, "namespace" => ns},
         "spec" => %{"greeting" => greeting}
       }) do
    deployment = gen_deployment(ns, name, greeting)
    service = gen_service(ns, name, greeting)

    %{
      deployment: deployment,
      service: service
    }
  end

  defp gen_service(ns, name, _greeting) do
    %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => %{
        "name" => name,
        "namespace" => ns,
        "labels" => %{"app" => name}
      },
      "spec" => %{
        "ports" => [%{"port" => 5000, "protocol" => "TCP"}],
        "selector" => %{"app" => name},
        "type" => "NodePort"
      }
    }
  end

  defp gen_deployment(ns, name, greeting) do
    %{
      "apiVersion" => "apps/v1",
      "kind" => "Deployment",
      "metadata" => %{
        "name" => name,
        "namespace" => ns,
        "labels" => %{"app" => name}
      },
      "spec" => %{
        "replicas" => 2,
        "selector" => %{
          "matchLabels" => %{"app" => name}
        },
        "template" => %{
          "metadata" => %{
            "labels" => %{"app" => name}
          },
          "spec" => %{
            "containers" => [
              %{
                "name" => name,
                "image" => "quay.io/coryodaniel/greeting-server",
                "env" => [%{"name" => "GREETING", "value" => greeting}],
                "ports" => [%{"containerPort" => 5000}]
              }
            ]
          }
        }
      }
    }
  end

  defp run(%K8s.Operation{} = op),
    do: K8s.Client.run(op, Bonny.Config.cluster_name())

  defp track_event(type, resource),
    do: Logger.info("#{type}: #{inspect(resource)}")
end
