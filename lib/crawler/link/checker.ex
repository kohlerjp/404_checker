defmodule Crawler.Link.Checker do
  alias Crawler.Link.Registry
  alias Crawler.Printer

  def verify_link(:done, _base_url, _depth) do
    :ok
  end
  def verify_link(link, base_url, depth) do
    case HTTPoison.get(base_url <> link) do
      {:ok, %HTTPoison.Response{status_code: code , body: body}} when code in 200..399 ->
        handle_success(link, body, depth)
      {:ok, %HTTPoison.Response{status_code: code}} -> handle_error(link, code)
      {:error, %HTTPoison.Error{reason: reason}}  -> handle_error(link, reason)
    end
  end

  defp handle_success(link, body, depth) do
    Printer.print_success()
    Registry.update_link(link, :ok)
    add_page_links(body, link, depth)
  end

  defp add_page_links(body, parent, depth) do
    body
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(&String.starts_with?(&1, "/"))
    |> Enum.map(&Registry.add_link(&1, parent, depth))
  end

  defp handle_error(link, reason) do
    Printer.print_error(link, reason)
    Registry.update_link(link, {:error, reason})
  end
end
