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

  defp main({:init, menu}) do
    parsed_menu = parse_menu(:init, menu)
    main(parsed_menu)
  end

  defp main(state) do
    receive do
      {:menu, pid} ->
	files_list = extract_file_list(state)
	send pid, files_list
    end
  end

  defp parse_menu(:init, menu) do
    {:ok, file_list} = File.ls(menu)
    parse_menu(menu, file_list)
  end

  defp parse_menu(menu, file_list) do
    case file_list do
      [] ->
	[]
      [ head ] ->
	parsed_file = parse_file(menu, head)
	case parsed_file do
	  {file_name, {_, %File.Stat{type: :directory}}} ->
	    [parsed_file] ++ parse_menu(:init, menu <> "/" <> file_name)
	    
	  {_, {_, %File.Stat{type: :regular}}} ->
	    [parsed_file]
	end
	
      [ head | tail ] ->
	parsed_file = parse_file(menu, head)
	case parsed_file do
	  {file_name, {_, %File.Stat{type: :directory}}} ->
	    [parsed_file] ++ parse_menu(:init, menu <> "/" <> file_name) ++
	      parse_menu(menu, tail)

	  {_, {_, %File.Stat{type: :regular}}} ->
	    [parsed_file] ++ parse_menu(menu, tail)
	end
    end
  end

  def parse_file(menu, file) do
    path = menu <> "/" <> file
    case File.stat(path) do
      {:ok, data} ->
	{file, {menu, data}}
      error ->
	{:error, error}
    end
  end

  def extract_file_list(directory_list) do
    directory_list
    |> Enum.filter(fn(file_info) ->
      case file_info do
	{_, {"files", _}} ->
	  true
	_Other ->
	  false
      end
    end)
  end
  
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
    [:binary, packet: 0, active: false])
    Logger.info "Accepting connections on port #{port}"
    spawn_main(:main)
    loop_accept(socket)
  end

  defp loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
  end

  #def spawn_main() do
  #  main_process = spawn_link(fn () -> main({:init, "files"}) end)
  #  Process.register(main_process, :main)
  #end

  def spawn_main(pid_identifier) do
    main_pid = spawn_link(fn () -> main({:init, "files"}) end)
    Process.register(main_pid, pid_identifier) 
  end
end
