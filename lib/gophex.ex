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
