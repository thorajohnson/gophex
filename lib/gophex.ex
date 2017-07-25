defmodule Gophex do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: Gophex.TaskSupervisor]])
    ]

    opts = [strategy: :one_for_one, name: Gophex.Supervisor]
    
    main_process = spawn(fn () -> main({:init, "files"}) end)
    Process.register(main_process, :main)

    Supervisor.start_link(children, opts)
  end

  defp main({:init, "files"}) do
    
  end
end
