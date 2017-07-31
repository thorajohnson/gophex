defmodule Gophex.GophexTest do
  use ExUnit.Case, async: false
  
  #setup do
  #  {:ok, gophex} = start_supervised(%{id: Gophex.Worker, start: {Gophex.Worker, :init, [4040]}})
 #   %{gophex: gophex}
 # end

  test "Supervisor is spawned when server is started" do
    supervisor_pid = Gophex.Supervisor.start("", "")
    assert is_pid(Process.whereis(Gophex.Supervisor))
  end

  test "can establish a TCP connection with Gophex" do
    worker_pid = spawn fn -> Gophex.Worker.accept(4040) end
    assert {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, 4040, [:binary, packet: 0, active: :once, reuseaddr: true])
    :ok = :gen_tcp.close(socket)
    Process.exit(worker_pid, :kill)
  end

  test "Sending empty string brings back file list on server" do
    Gophex.Agent.start_link({})
    main_pid = Process.whereis(:main)
    assert is_list(Gophex.Agent.get_menu(:main, :menu))
  end

  test "All command sends all files currently on Gopher server" do
    Gophex.Agent.start_link({})
    file_list = Gophex.Agent.get_menu(:main, :all)    
    assert is_list(file_list)
    assert length(file_list) > Gophex.Agent.get_menu(:main, :menu)
  end
end
