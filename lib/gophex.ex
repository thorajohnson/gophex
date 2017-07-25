defmodule Gophex do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: Gophex.TaskSupervisor]]),
      worker(Task, [Gophex, :accept, [4040]])
    ]

    opts = [strategy: :one_for_one, name: Gophex.Supervisor]
    
    main_process = spawn(fn () -> main({:init, "files"}) end)
    Process.register(main_process, :main)

    Supervisor.start_link(children, opts)
  end

  defp main({:init, "files"}) do
    
  end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
      [:binary, packet: 0, active: false])
    Logger.info "Accepting connections on port #{port}"
    loop_accept(socket)
  end

  defp loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
  end
end
