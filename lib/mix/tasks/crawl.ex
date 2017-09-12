defmodule Mix.Tasks.Crawl do
  @moduledoc """
  Mix task to parse options and crawl the given site
  """
  use Mix.Task

  def run(argv) do
    [url | user_opts] = argv
    strict_params = [max_depth: :integer, num_workers: :integer]
    {command_opts, _, _} = OptionParser.parse(user_opts, strict: strict_params)
    Application.ensure_all_started(:httpoison)
    opts = Keyword.merge(command_opts, [base_url: url])
    {:ok, pid} = Crawler.Supervisor.start_link(opts)
    Process.monitor(pid)
    receive do
      _ -> System.halt(0)
    end
  end
end
