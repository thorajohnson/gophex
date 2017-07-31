defmodule Gophex.Worker do
  use Application
  require Logger

  #def child_spec(opts) do
  #  %{
  #    id: __MODULE__,
  #    start: {__MODULE__, :accept, [opts]},
  #    type: :worker,
  #    restart: :temporary,
  #    shutdown: 500
  #  }
  #end

  #def init(_arg) do
  #  spawn_main()
  #end
  
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
      [:binary, packet: 0, active: false])
    Logger.info "Accepting connections on port #{port}"
    #spawn_main(:main)
    loop_accept(socket)
  end

  defp loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
  end

  #def spawn_main() do
  #  main_process = spawn_link(fn () -> main({:init, "files"}) end)
  #  Process.register(main_process, :main)
  #end

  #def spawn_main(pid_identifier) do
  #  main_pid = spawn_link(fn () -> main({:init, "files"}) end)
  #  Process.register(main_pid, pid_identifier) 
  #end
end
