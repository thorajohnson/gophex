defmodule Gophex.Supervisor do
  import Supervisor.Spec

    def start(_type, _args) do
    children = [
      supervisor(Task.Supervisor, [[name: Gophex.TaskSupervisor]]),
      worker(Task, [Gophex.Worker, :accept, [4040]]),
      worker(Agent, [Gophex.Agent, :start_link])
    ]

    opts = [strategy: :one_for_one, name: Gophex.Supervisor]

    Supervisor.start_link(children, opts)
  end

    
end
