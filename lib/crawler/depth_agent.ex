defmodule Crawler.DepthAgent do
  @moduledoc """
  Keeps track of the current depth travelled
  """
  use Agent

  def start_link([]) do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def increase_depth() do
    Agent.update(__MODULE__, fn d -> d + 1 end)
  end

  def current_depth() do
    Agent.get(__MODULE__, fn d -> d end)
  end
end
