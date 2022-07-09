defmodule Mix.Tasks.Start do
  use Mix.Task

  def run(args) do
    filename = hd(args)
    {:ok, matches_json} = File.read(filename)

    Jason.decode!(matches_json)
    |> SuperLeague.create_table()
    |> SuperLeague.format_table()
    |> IO.puts()
  end
end
