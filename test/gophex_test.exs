defmodule Gophex.GophexTest do
  use ExUnit.Case, async: false
  
  test "Supervisor is spawned when server is started" do
    supervisor_pid = Gophex.Supervisor.start("", "")
    assert is_pid(Process.whereis(Gophex.Supervisor))
  end

  test "can establish a TCP connection with Gophex" do
    worker_pid = spawn fn -> Gophex.Worker.accept(4040) end
    assert {:ok, socket} = :gen_tcp.connect('0.0.0.0', 4040, [:binary, packet: 0, active: false, reuseaddr: true])
    :ok = :gen_tcp.close(socket)
    Process.exit(worker_pid, :kill)
  end

  test "connecting to server sends back top-level file menu" do
    worker_pid = spawn fn -> Gophex.Worker.accept(4040) end
      {:ok, socket} = :gen_tcp.connect('0.0.0.0', 4040, [:binary, packet: 0, active: false])
      menu_string = (:gen_tcp.send(socket, ""))
      assert is_binary(menu_string)
      assert String.contains?(menu_string, File.ls("files"))
      :ok = :gen_tcp.close(socket)
      Process.exit(worker_pid, :kill)
  end
end
