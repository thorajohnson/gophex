defmodule Gophex.GophexTest do
  use ExUnit.Case, async: false
  
  #setup do
  #  {:ok, gophex} = start_supervised(%{id: Gophex.Worker, start: {Gophex.Worker, :init, [4040]}})
 #   %{gophex: gophex}
 # end

  test "Main process is spawned"  do
    Gophex.Worker.spawn_main(:main_process)
    main_pid = Process.whereis(:main_process)
    assert is_pid(main_pid)
    Process.exit(main_pid, :kill)
  end

  test "Supervisor is spawned when server is started" do
    supervisor_pid = Gophex.Supervisor.start("", "")
    assert is_pid(Process.whereis(Gophex.Supervisor))
  end

  test "can establish a TCP connection with Gophex" do
    worker_pid = spawn fn -> Gophex.Worker.accept(4040) end
    assert {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, 4040, [:binary, packet: 0, active: :once])
    :ok = :gen_tcp.close(socket)
    Process.exit(worker_pid, :kill)
  end

  test "Sending empty string brings back file list on server" do
    Gophex.Worker.spawn_main(:test_main)
    main_pid = Process.whereis(:test_main)
    send :test_main, {:menu, self()}
    receive do
      files_list ->
	assert is_list(files_list)
	Process.exit(main_pid, :kill)
    after
      1_000 ->
	assert false
	Process.exit(main_pid, :kill)
    end
  end
end
