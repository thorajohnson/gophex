defmodule Gophex.Agent do
  use Agent

  defmodule FileData do
    defstruct path: "", data: %File.Stat{}
  end
  
  def start_link() do
        Agent.start_link(fn -> create_file_list("files") end, name: :main)
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

  defp create_file_list(dir) do
    File.ls!("files")
    |> Enum.map(fn(file) -> {file, Path.join("files", file)} end) 
    |> Enum.into(%{})
  end

  def get_server_menu(directory_list) do
    Enum.filter(directory_list, fn({_, file_info}) ->
      #IO.inspect file_info
      #match?({:path, "files"}, file_info)
    if count_slashes(String.codepoints(file_info.path), 0) > 1 do
      false
    else
      true
    end
    end)
  end

  defp count_slashes(char_list, count) do
    case char_list do
      [ head ] ->
	if head == "/" do
	  count + 1
	else
	  count
	end
      [ head | tail ] ->
	if head == "/" do
	  count_slashes(tail, count + 1)
	else 
	  count_slashes(tail, count)
	end
    end
  end
end
