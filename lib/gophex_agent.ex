defmodule Gophex.Agent do
  use Agent

  defmodule FileList do
    defstruct path: "", data: %File.Stat{}
  end
  
  def start_link(_opts) do
        Agent.start_link(fn -> main({:init, "files"}) end, name: :main)
  end

  defp main({:init, menu}) do
    parse_menu(:init, menu)
  end

  def get(file_list, :menu) do
    Agent.get(file_list, &extract_file_list(&1))
  end

  def get(file_list, :all) do
    Agent.get(file_list, fn (files) -> files end)
  end

  def get(file_list, :get, file_name) do
    Agent.get(file_list, fn (files) ->
      case  Map.fetch(files, file_name) do
	{:ok, file} ->
	  file
	:error ->
	  :error
      end
    end)
  end
   
  defp parse_menu(:init, menu), do: parse_menu(:init, menu, %{})

  defp parse_menu(:init, menu, parsed_list) do
    {:ok, file_list} = File.ls(menu)
    parse_menu(menu, file_list, parsed_list)
  end

  defp parse_menu(menu, file_list, parsed_list) do
    case file_list do
      [] ->
	parsed_list
      [ head ] ->
	parsed_list = parse_file(menu, head, parsed_list)
	case Map.fetch!(parsed_list, head)  do
	  %FileList{data: %File.Stat{type: :directory}} ->
	    parse_menu(:init, menu <> "/" <> head, parsed_list)
	    
	  %FileList{data: %File.Stat{type: :regular}} ->
	    parsed_list
	end
	
	[ head | tail ] ->
	parsed_list = parse_file(menu, head, parsed_list)
	case Map.fetch!(parsed_list, head) do
	  %FileList{data: %File.Stat{type: :directory}} ->
	    parse_menu(:init, menu <> "/" <> head, parsed_list)
	    |>  (&parse_menu(menu, tail, &1)).()

	  %FileList{data:  %File.Stat{type: :regular}} ->
	    parse_menu(menu, tail, parsed_list)
	end
    end
  end

  def parse_file(menu, file, parsed_list) do
    path = menu <> "/" <> file
    case File.stat(path) do
      {:ok, data} ->
	Map.put(parsed_list, file, %FileList{path: path, data: data})
      error ->
	{:error, error}
    end
  end

  def extract_file_list(directory_list) do
    directory_list
    |> Enum.filter(fn(file_info) ->
      match?({:path, "files"}, file_info)
    end)
  end
end
