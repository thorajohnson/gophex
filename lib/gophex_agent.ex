defmodule Gophex.Agent do
  use Agent

  defmodule FileData do
    defstruct path: "", type: :other
  end
  
  def start_link(_opts), do: start_link()
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
    |> create_file_list("files")
    |> List.flatten()
    |> Enum.into(%{})
  end

  defp create_file_list(file_list, dir) do
    case file_list do
      [head] ->
	[create_file_entry(head, dir)]
      [head|tail] ->
	[create_file_entry(head, dir)] ++ create_file_list(tail, dir) 
    end
  end 

  defp create_file_entry(file, dir) do
    path = Path.join(dir, file)
      cond do
	File.regular? path -> 
	  {file, %FileData{path: path, type: :regular}}
        File.dir? path ->
          create_file_list(File.ls!(path), path) ++	
	  [{file, %FileData{path: path, type: :directory}}]
	true ->
	  {file, %FileData{path: path, type: :other}}  
      end
  end      

  def get_server_menu(directory_list) do
    Enum.filter(directory_list, fn({_, file_info}) ->
      file_info.path
      |> String.codepoints()
      |> Enum.count(fn (char) -> char == "/" end)
      |> only_one_slash?()
    end)
  end

  defp only_one_slash?(count), do: count == 1
end
