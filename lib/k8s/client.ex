defmodule K8s.Client do
  @moduledoc """
  This is a very simple k8s client.

  *It is not production worthy.*
  """
  alias K8s.Conf.RequestOptions
  require Logger

  def post(body, conf) do
    path = body_to_path(body, false)
    url = Path.join(conf.url, path)
    [headers, options] = parse_config(conf)
    body = Poison.encode!(body)

    Logger.info("[POST] #{url}")

    url
    |> HTTPoison.post(body, headers, options)
    |> handle_response
  end

  def patch(body, conf) do
    path = body_to_path(body, true)
    url = Path.join(conf.url, path)
    [headers, options] = parse_config(conf)
    body = Poison.encode!(body)

    Logger.info("[PATCH] #{url}")

    url
    |> HTTPoison.patch(body, headers, options)
    |> handle_response
  end

  def delete(body, conf) do
    path = body_to_path(body, true)
    url = Path.join(conf.url, path)
    [headers, options] = parse_config(conf)

    Logger.info("[DELETE] #{url}")

    url
    |> HTTPoison.delete(headers, options)
    |> handle_response
  end

  defp handle_response(resp) do
    case resp do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code >= 200 and code < 300 ->
        :ok

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        msg = "HTTP Error code: #{code} #{body}"
        Logger.error(msg)
        {:error, msg}

      {:error, %HTTPoison.Error{reason: reason}} ->
        msg = "HTTPoison.Error; #{reason}"
        Logger.error(msg)
        {:error, msg}
    end
  end

  defp body_to_path(spec = %{}, include_name) do
    %{
      apiVersion: vsn,
      kind: kind,
      metadata: %{namespace: ns, name: name}
    } = spec

    path_root =
      case String.contains?(vsn, "/") do
        true -> "/apis"
        false -> "/api"
      end

    base_path = "#{path_root}/#{vsn}/namespaces/#{ns}/#{String.downcase(kind)}s"

    if include_name do
      "#{base_path}/#{name}"
    else
      base_path
    end
  end

  defp parse_config(conf) do
    request_options = RequestOptions.generate(conf)

    headers =
      request_options.headers ++
        [{"Accept", "application/json"}, {"Content-Type", "application/json"}]

    options = [ssl: request_options.ssl_options]

    [headers, options]
  end
end
