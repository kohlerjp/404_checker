defmodule DepthAgentTest do
  use ExUnit.Case
  import Crawler.DepthAgent

  test "Depth agent can increase depth and return current depth" do
    {:ok, _agent} = start_supervised(Crawler.DepthAgent)
    assert current_depth() == 0
    increase_depth()
    assert current_depth() == 1
    increase_depth()
    assert current_depth() == 2
  end
end
