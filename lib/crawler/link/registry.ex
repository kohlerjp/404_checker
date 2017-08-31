defmodule Crawler.Link.Registry do
  alias Crawler.Link
  use GenServer

  # Client
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, "/", name: __MODULE__)
  end

  def unchecked_links(depth) do
    GenServer.call(__MODULE__, {:unchecked_links, depth})
  end

  def broken_links() do
    GenServer.call(__MODULE__, :broken_links)
  end

  def add_link(link, parent, depth) do
    GenServer.cast(__MODULE__, {:add_link, {link, {:unknown, parent, depth}}})
  end

  def update_link(link, result) do
    GenServer.cast(__MODULE__, {:update_link, {link, result}})
  end

  @doc "Reset any links that may have been dropped"
  def reset_dropped() do
    GenServer.cast(__MODULE__, :reset_processing)
  end

  # Server
  def init(first_link) do
    {:ok, %{first_link => %Link{url: first_link}}}
  end

  def handle_call({:unchecked_links, depth}, _from, links) do
    {:reply, unchecked_links(links, depth), links}
  end
  def handle_call(:broken_links, _from, links) do
    broken_links = Enum.filter(links, fn {_url, link} -> match?({:error, _val}, link.result) end)
    {:reply, broken_links, links}
  end

  def handle_cast({:add_link, {url, {result, parent, depth}}}, links) do
    {:noreply, Map.update(links, url, %Link{url: url, parent: parent, result: result, depth: depth + 1}, fn val -> val end)}
  end

  def handle_cast({:update_link, {url, status}}, links) do
    {:noreply, Map.update!(links, url, fn link -> %{link | result: status} end)}
  end
  def handle_cast(:reset_processing, links) do
      new_links = links
      |> Enum.map(fn {url, link} -> {url, Link.reset_link(link)} end)
      |> Map.new()
      {:noreply, new_links}
  end

  defp unchecked_links(links, depth) do
    links
    |> Enum.filter(fn {_url, link} -> link.result == :unknown && link.depth == depth end)
    |> Enum.map(fn {url, _link} -> url end)
  end
end
