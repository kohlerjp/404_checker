defmodule Mix.Tasks.Crawl do
  use Mix.Task

  def run(argv) do
    [url | user_opts] = argv
    {opts, _, _} = OptionParser.parse(user_opts, strict: [max_depth: :integer, num_workers: :integer])
    Application.ensure_all_started(:httpoison)
    {:ok, pid} = Crawler.Supervisor.start_link(Keyword.merge(opts, [base_url: url]))
    Process.monitor(pid)
    receive do
      _ -> System.halt(0)
    end
  end
end
