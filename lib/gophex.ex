defmodule Gophex do
  use Application
  require Logger

  defp main({:init, "files"}) do
    
  end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
    [:binary, packet: 0, active: false])
    Logger.info "Accepting connections on port #{port}"
    spawn_main()
    loop_accept(socket)
  end

  defp loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
  end

  def spawn_main() do
    main_process = spawn(fn () -> main({:init, "files"}) end)
    Process.register(main_process, :main)
  end
end
