defmodule Gophex.Agent do
  use Agent

  defmodule FileData do
    defstruct path: "", data: %File.Stat{}
  end
  
  def start_link() do
        Agent.start_link(fn -> parse_menu(:init, "files") end, name: :main)
  end

  def get(file_list, :menu) do
    Agent.get(file_list, &get_server_menu(&1))
  end

  def get(file_list, :all) do
    Agent.get(file_list, fn (files) -> files end)
  end

  def get(file_list, :get, file_name) do
    Agent.get(file_list, &fetch_file(&1, file_name))
  end

  def get(file_list, :getdir, dir_name) do
    Agent.get(file_list, &fetch_dir(&1, dir_name))
  end
  
  defp fetch_file(files, file_name) do
    case  Map.fetch(files, file_name) do
	{:ok, file} ->
	  file
	:error ->
	  :error
      end
  end

  defp fetch_dir(files, dir_name) do
    dir_path = dir_name <> "/"
    Enum.filter(files, fn({_, file}) ->
      String.contains?(file.path, dir_path) 
    end)
  end
   
  defp parse_menu(:init, menu), do: parse_menu(:init, menu, %{})

  defp parse_menu(:init, menu, parsed_map) do
    {:ok, file_list} = File.ls(menu)
    parse_menu(menu, file_list, parsed_map)
  end

  defp parse_menu(menu, file_list, parsed_map) do
    case file_list do
      [] ->
	parsed_map
	
      [ head ] -> 
	parsed_map = parse_file(menu, head, parsed_map)
	case Map.fetch!(parsed_map, head)  do
	  %FileData{data: %File.Stat{type: :directory}} ->
	    parse_menu(:init, menu <> "/" <> head, parsed_map)
	    
	  %FileData{data: %File.Stat{type: :regular}} ->
	    parsed_map
	end
	
      [ head | tail ] ->
	parsed_map = parse_file(menu, head, parsed_map)
	case Map.fetch!(parsed_map, head) do
	  %FileData{data: %File.Stat{type: :directory}} ->
	    parse_menu(:init, menu <> "/" <> head, parsed_map)
	    |>  (&parse_menu(menu, tail, &1)).()

	  %FileData{data:  %File.Stat{type: :regular}} ->
	    parse_menu(menu, tail, parsed_map)
	end
    end
  end

  def parse_file(menu, file, parsed_map) do
    path = menu <> "/" <> file
    case File.stat(path) do
      {:ok, data} ->
	Map.put(parsed_map, file, %FileData{path: path, data: data})
      error ->
	{:error, error}
    end
  end

  def get_server_menu(directory_list) do
    directory_list
    |> Enum.filter(fn(file_info) ->
      match?({:path, "files"}, file_info)
    end)
  end
end
