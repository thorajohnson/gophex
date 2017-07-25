defmodule Gophex do
  use Application
  require Logger

  def start(_type, _args) do
    main_proccess = spawn(fn () -> main({:init, "files"}) end)
    |> Process.register(:main)
  end

  defp main({:init, "files"}) do
    
  end
end
