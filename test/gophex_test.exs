defmodule GophexTest do
  use ExUnit.Case, async: true
  doctest Gophex

  test "Main process is spawned" do
    Gophex.spawn_main()
    assert is_pid(Process.whereis(:main))
  end

  test "Supervisor is spawned when server is started" do
    Gophex.Supervisor.start("", "")
    assert is_pid(Process.whereis(Gophex.Supervisor))
  end

  test "can establish a TCP connection with Gophex" do
    spawn fn -> Gophex.accept(4040) end
    assert {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, 4040, [:binary, packet: 0, active: :once])
    :ok = :gen_tcp.close(socket)
  end

  test "Sending empty string brings back file list on server" do
    Gophex.spawn_main()
    send :main, {:menu, self()}
    receive do
      files_list ->
	assert is_binary(files_list)
    after
      1_000 -> assert false
    end
  end
end
