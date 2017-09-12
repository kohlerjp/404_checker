defmodule Crawler.Supervisor do
  alias Crawler.{Link.Registry, DepthAgent}

  import Supervisor.Spec

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    children = [
      Registry,
      DepthAgent
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
