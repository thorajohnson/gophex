defmodule Gophex.Worker do
  #use Application
  require Logger
  
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
      [:binary, packet: 0, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_accept(socket)
  end

  defp loop_accept(loop_socket) do
    {:ok, client} = :gen_tcp.accept(loop_socket)
    {:ok, pid} = Task.Supervisor.start_child(Gophex.TaskSupervisor,
      fn -> loop(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    #:gen_tcp.controlling_process(client, spawn fn () -> loop(client) end)
    loop_accept(loop_socket)
  end

  defp loop(socket) do
    #:inet.setopts(socket, active: :once)
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
	case to_charlist(data) do
	  [13, 10] ->
	    :gen_tcp.send(socket, send_server_menu())
	  file ->
	    cleaned_file = file |> to_string |> String.trim
	    :gen_tcp.send(socket, send_file_or_dir(cleaned_file))
	end
	loop(socket)

      {:error, :closed} -> IO.puts("connection closed")	
    end
  end

  defp send_server_menu() do
    menu = Gophex.Agent.get(:main, :menu)
    |> menu_to_string()
  end

  defp send_file_or_dir(path) do
    if Regex.match?(~r/\.[^.]+/, path) do
      send_file(path)
    end
  end

  defp send_file(file) do
    file = Gophex.Agent.get(:main, :get, file)
    case File.read(file.path) do
      {:ok, file_bin} -> file_bin
      {:error, error} -> error
    end
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
