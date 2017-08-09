defmodule Gophex.Worker do
  use Application
  require Logger
  
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
      [:binary, packet: 0, active: false])
    Logger.info "Accepting connections on port #{port}"
    loop_accept(socket)
  end

  defp loop_accept(loop_socket) do
    {:ok, client} = :gen_tcp.accept(loop_socket)
    :gen_tcp.controlling_process(client, spawn fn () -> loop(client) end)
    loop_accept(loop_socket)
  end

  defp loop(socket) do
    :inet.setopts(socket, active: :once)
    receive do
      {:tcp, socket, data} ->
	case to_charlist(data) do
	  [13, 10] ->
	    :gen_tcp.send(socket, send_server_menu())
	  other ->
	    IO.puts "Invalid data"
	    :invalid_data
	end
    end
  end

  defp send_server_menu() do
    menu = Gophex.Agent.get(:main, :menu)
    |> menu_to_string()
  end

  defp menu_to_string(file_list) do
    case file_list do
      [ head ] ->
	file_to_string(head) 

      [ head | tail ] ->
	file_to_string(head) <> menu_to_string(tail)
    end
  end

  defp file_to_string({file_name, file}) do
    case file.type do
      :directory ->
	"1" <> file_name <> "\t" <> file.path <> "\tlocalhost\t7000\r\n"

      :regular ->
	"0" <> file_name <> "\t" <> file.path <> "\t localhost\t7000\r\n"
    end
  end
end
