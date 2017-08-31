defmodule Crawler.Link do

  @type result :: :unknown | :ok | {:error, integer | atom} | :processing

  defstruct [
    url: "",
    parent: nil,
    depth: 0,
    result: :unknown
  ]

  @type t :: %__MODULE__{
    url: String.t,
    parent: String.t,
    depth: integer,
    result: result
  }

  def reset_link(%__MODULE__{result: :processing} = link), do: %{link | result: :unknown}
  def reset_link(%__MODULE__{} = link), do: link
end
