defmodule Gophex.GophexAgentTest do
  use ExUnit.Case, async: false

  test "Agent process is spawned"  do
    main_pid = Process.whereis(:main)
    assert is_pid(main_pid)
  end

  test "Sending empty string brings back file list on server" do
    menu = Gophex.Agent.get(:main, :menu)
    file_list = File.ls!("files")
    assert is_list(file_list)
    assert Enum.all?(menu, fn ({menu_file, _}) -> 
      Enum.any?(file_list, fn (file) -> menu_file == file end)
    end)
  end

  test "Agent contains the files one level within files directory" do
    file_map = Gophex.Agent.get(:main, :all)
    assert File.ls!("files") |> Enum.all?(&Map.has_key?(file_map, &1)) 
  end

  test "Agent stores the file path for files and directories" do
    file_map = Gophex.Agent.get(:main, :all)
    assert file_map["gopher_facts"].path == "files/gopher_facts"
  end

  test "Agent stores whether a file is a directory or a file" do
    file_map = Gophex.Agent.get(:main, :all)
    assert file_map["gopher.txt"].type == :regular
  end
  
  test "Agent stores all files currently on server" do
    server_files = Gophex.Agent.get(:main, :all)
    file_list = Path.wildcard("files/**")
    |> Enum.map(fn (path) -> String.split(path, "/") |> List.last end)
    assert map_size(server_files) == length(file_list)
    assert file_list |> Enum.all?(&Map.has_key?(server_files, &1))
  end

  test "All command sends all files currently on Gopher server" do
    file_map = Gophex.Agent.get(:main, :all)    
    assert is_map(file_map)
    assert map_size(file_map) > length(Gophex.Agent.get(:main, :menu))
  end

  test "Get command sends requested file" do
    file = Gophex.Agent.get(:main, :get, "gopher_facts.txt")
    assert Map.has_key?(file, :__struct__)
    {:ok, file_stat} = File.stat(file.path)
    assert file.type == file_stat.type
  end

  test "GetDir command sends contents of requested directory" do
    dir = Gophex.Agent.get(:main, :getdir, "test_dir")
    assert is_list(dir)

    {:ok, dir_contents} = File.ls("files/test_dir")
    assert length(dir) == length(dir_contents) 
  end
end
