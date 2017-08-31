defmodule Crawler.Supervisor do
  alias Crawler.{Link.Registry, DepthAgent, Dispatcher}

  use Supervisor
  import Supervisor.Spec

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    children = [
      Registry,
      DepthAgent,
      worker(Dispatcher, [opts], restart: :transient),
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
