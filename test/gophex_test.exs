defmodule Gophex.GophexTest do
  use ExUnit.Case, async: false
  
  test "Supervisor is spawned when server is started" do
    assert is_pid(Process.whereis(Gophex.Supervisor))
  end

  test "connecting to server sends back top-level file menu" do
    #Gophex.Agent.start_link()
    #worker_pid = spawn_link(fn -> Gophex.Worker.accept(4040) end)
    assert {:ok, socket} = :gen_tcp.connect('0.0.0.0', 4040, [:binary, packet: 0, active: :false, reuseaddr: true])
    :gen_tcp.send(socket, "\r\n")
    {:ok, menu} = :gen_tcp.recv(socket, 0)
    assert is_binary(menu)
    {:ok, menu_files} = File.ls("files")
    assert String.first(menu) == "0" 
    assert String.contains?(menu, menu_files)
    :gen_tcp.send(socket, "gopher.txt\r\n")
    {:ok, file} = :gen_tcp.recv(socket, 0)
    assert String.trim(file) == "Welcome to Gopher!" 
    #:ok = :gen_tcp.close(socket)
    #Process.exit(worker_pid, :kill)
  end
end
