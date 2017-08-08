defmodule Gophex.GophexAgentTest do
  use ExUnit.Case, async: false

  test "Agent process is spawned"  do
    Gophex.Agent.start_link()
    main_pid = Process.whereis(:main)
    assert is_pid(main_pid)
  end

  #test "Sending empty string brings back file list on server" do
  #  Gophex.Agent.start_link()
  #  assert is_list(Gophex.Agent.get(:main, :menu))
  #end

  test "Agent contains the files one level within files directory" do
    Gophex.Agent.start_link()
    file_map = Gophex.Agent.get(:main, :all)
    assert File.ls!("files") |> Enum.all?(&Map.has_key?(file_map, &1)) 
  end  
  
  #test "Agent stores all files currently on server" do
  #  Gophex.Agent.start_link()
  #  file_list = Gophex.Agent.get(:main, :all)
  #  assert map_size(file_list) == length(Path.wildcard("files/**"))
  #end

#  test "All command sends all files currently on Gopher server" do
#    Gophex.Agent.start_link()
#    file_list = Gophex.Agent.get(:main, :all)    
#    assert is_map(file_list)
#    assert map_size(file_list) > length(Gophex.Agent.get(:main, :menu))
#  end

#  test "Get command sends requested file" do
#    Gophex.Agent.start_link()
#    file = Gophex.Agent.get(:main, :get, "gopher_facts.txt")
#    assert Map.has_key?(file, :__struct__)
#    
#    {:ok, file_stat} = File.stat(file.path) 
#    assert file.data == file_stat
#  end

#  test "GetDir command sends contents of requested directory" do
#    Gophex.Agent.start_link()
#    dir = Gophex.Agent.get(:main, :getdir, "test_dir")
#    assert is_list(dir)
#
#    {:ok, dir_contents} = File.ls("files/test_dir")
#    assert length(dir) == length(dir_contents) 
#  end
end
