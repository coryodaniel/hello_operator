use Mix.Config

config :logger, level: :debug

if Mix.env() == :dev do
  config :bonny, kubeconf_file: "./kubeconfig.yaml"
end

config :bonny,
  # Add each CRD Controller module for this operator to load here
  # Defaults to all implementations of Bonny.Controller
  controllers: [
    HelloOperator.Controller.V1.Greeting
  ]

#   # Set the Kubernetes API group for this operator.
#   # This can be overwritten using the @group attribute of a controller
#   group: "your-operator.example.com",

#   # Name must only consist of only lowercase letters and hyphens.
#   # Defaults to hyphenated mix app name
#   operator_name: "your-operator",

#   # Name must only consist of only lowercase letters and hyphens.
#   # Defaults to hyphenated mix app name
#   service_account_name: "your-operator",

#   # Labels to apply to the operator's resources.
#   labels: %{
#     "kewl": "true"
#   },

#   # Operator deployment resources. These are the defaults.
#   resources: %{
#     limits: %{cpu: "200m", memory: "200Mi"},
#     requests: %{cpu: "200m", memory: "200Mi"}
#   },

#   # Defaults to "current-context" if a config file is provided, override user, cluster. or context here
#   kubeconf_opts: []
