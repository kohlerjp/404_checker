defmodule Crawler.Printer do
  alias Crawler.Link.Registry


  def print_info(time, max_depth, []) do
    IO.puts("\n#{IO.ANSI.green()}PASSED SUCCESSFULLY#{IO.ANSI.white()}")
    print_time(time)
    print_unchecked_links(max_depth)
  end
  def print_info(time, max_depth, broken_links) do
    print_time(time)
    IO.puts("\n#{IO.ANSI.red()}Finished with #{Enum.count(broken_links)} errors #{IO.ANSI.white()}")
    IO.puts("Broken Links: #{inspect(broken_links)}")
    print_unchecked_links(max_depth)
  end

  defp print_unchecked_links(max_depth) do
    unchecked_count = Registry.unchecked_links(max_depth + 1) |> Enum.count
    IO.puts("#{unchecked_count} links not checked")
  end

  def print_error(link, reason), do: Task.async(fn -> do_print_error(link, reason) end)

  def do_print_error(link, reason) do
    IO.write(IO.ANSI.red())
    IO.puts("\nFAILED #{link}")
    IO.puts("REASON: #{reason}")
    IO.write(IO.ANSI.white())
  end

  def print_success() do
    Task.async(fn -> IO.write("#{IO.ANSI.green()}.#{IO.ANSI.white()}") end)
  end

  defp print_time(time) do
    seconds = (time / 1000000) |> Float.round(2)
    IO.puts("Finished in #{seconds} seconds (#{(seconds / 60) |> Float.round(2)} minutes)")
  end
end
