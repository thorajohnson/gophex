defmodule Gophex.Agent do
  use Agent

  def start_link(_opts) do
        Agent.start_link(fn -> main({:init, "files"}) end, name: :main)
  end

  defp main({:init, menu}) do
    parse_menu(:init, menu)
    #parsed_menu = parse_menu(:init, menu)
    #main(parsed_menu)
  end

  def get_menu(file_list, :menu) do
    Agent.get(file_list, &extract_file_list(&1))
  end

  def get_menu(file_list, :all) do
    Agent.get(file_list, fn (files) -> files end)
  end
    

  #defp main(state) do
  #  receive do
  #    {:menu, pid} ->
  #	files_list = extract_file_list(state)
  #	send pid, files_list
  #  end
  #end

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
end
