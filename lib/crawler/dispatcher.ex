defmodule Crawler.Dispatcher do
  @moduledoc """
  Loops through remaining links and creates tasks to check those links for validity
  """
  alias Crawler.{Link.Registry, Link.Checker, Printer, DepthAgent}

  @default_opts [max_depth: 3, workers: 20, base_url: "http://localhost:4001"]

  def start_link(user_opts) do
    opts = Keyword.merge(@default_opts, user_opts)
    Task.start_link(fn -> loop(opts) end)
  end

  def loop(opts) do
    {time, invalid_links} = :timer.tc(fn -> do_loop(opts) end)
    Printer.print_info(time, opts[:max_depth], invalid_links)
    invalid_links |> pass_fail() |> System.halt()
  end

  defp do_loop(opts) do
    current_depth = DepthAgent.current_depth()
    Registry.reset_dropped()
    num_workers = opts[:workers]
    for depth <- current_depth..opts[:max_depth] do
      depth
      |> Registry.unchecked_links()
      |> Enum.split(num_workers)
      |> process_list(opts[:base_url], depth, num_workers)
      DepthAgent.increase_depth()
    end
    Registry.invalid_links()
  end

  defp process_list({[], []}, _base_url, _depth, _num_workers), do: :ok
  defp process_list({links, []}, base_url, depth, _num_workers) do
    do_process(links, base_url, depth)
    :ok
  end
  defp process_list({links, rest}, base_url, depth, num_workers) do
    do_process(links, base_url, depth)
    rest
    |> Enum.split(num_workers)
    |> process_list(base_url, depth, num_workers)
  end

  defp do_process(links, base_url, depth) do
    verify = fn link -> Checker.verify_link(link, base_url, depth) end
    links
    |> Task.async_stream(verify, timeout: 10_500)
    |> Enum.map(& &1)
  end

  defp pass_fail([]), do: 0
  defp pass_fail(_), do: 1
end
