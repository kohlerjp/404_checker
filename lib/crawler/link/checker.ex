defmodule Crawler.Link.Checker do

  @moduledoc """
  Checks Links to determine if they are valid or not. Adds links
  from valid urls to the registry for processing.
  """
  alias Crawler.Link.Registry
  alias Crawler.Printer

  def verify_link(:done, _base_url, _depth) do
    :ok
  end
  def verify_link(link, base_url, depth) do
    case HTTPoison.get(base_url <> link, recv_timeout: 10_000) do
      {:ok, %HTTPoison.Response{status_code: code} = response} when code in 200..399 ->
        handle_success(link, response, depth, base_url)
      {:ok, %HTTPoison.Response{status_code: code}} -> handle_error(link, code)
      {:error, %HTTPoison.Error{reason: reason}}  -> handle_error(link, reason)
    end
  end

  defp handle_success(link, response, depth, base_url) do
    Printer.print_success()
    Registry.update_link(link, :ok)
    add_page_links(response, link, depth, base_url)
  end

  defp add_page_links(response, parent, depth, base_url) do
    content_type = response.headers |> Map.new() |> Map.get("content-type", "")
    if String.match?(content_type, ~r/text\/html/) do
      do_add_page_links(response.body, parent, depth, base_url)
    else
      :ok
    end
  end

  defp do_add_page_links(body, parent, depth, base_url) do
    body
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(&internal_link?(&1, base_url))
    |> Enum.map(&Registry.add_link(link_path(&1), parent, depth))
  end

  defp handle_error(link, reason) do
    Printer.print_error(link, reason)
    Registry.update_link(link, {:error, reason})
  end

  defp internal_link?(url, base_url) do
    String.starts_with?(url, "/") || URI.parse(url).host == URI.parse(base_url).host
  end

  defp link_path(url) do
    URI.parse(url).path
  end
end
