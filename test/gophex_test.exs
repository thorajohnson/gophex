defmodule Gophex.GophexTest do
  use ExUnit.Case, async: false

  @tcp_options [:binary, packet: 0, active: :false, reuseaddr: true]
  
  test "Supervisor is spawned when server is started" do
    assert is_pid(Process.whereis(Gophex.Supervisor))
  end

  test "connecting to server sends back top-level file menu" do
    assert {:ok, socket} = :gen_tcp.connect('0.0.0.0', 4040, @tcp_options)

    :gen_tcp.send(socket, "\r\n")
    {:ok, menu} = :gen_tcp.recv(socket, 0)
    {:ok, menu_files} = File.ls("files")
    assert is_binary(menu)
    assert String.first(menu) == "0" 
    assert String.contains?(menu, menu_files)

    :gen_tcp.send(socket, "gopher.txt\r\n")
    {:ok, file} = :gen_tcp.recv(socket, 0)
    assert String.trim(file) == "Welcome to Gopher!"

    :gen_tcp.send(socket, "\r\ntest_dir\r\n")
    {:ok, dir} = :gen_tcp.recv(socket, 0)
    {:ok, test_dir} = File.ls("files/test_dir")
    assert String.first(dir) == "0"
    assert String.contains?(dir, test_dir)
    assert String.contains?(dir, "localhost")
  end
end
