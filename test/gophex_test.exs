defmodule GophexTest do
  use ExUnit.Case, async: true
  doctest Gophex

  test "Main process is spawned" do
    Gophex.start("", "")
    assert is_pid(Process.whereis(:main))
  end

  test "Supervisor is spawned when server is started" do
    Gophex.start("", "")
    assert is_pid(Process.whereis(Gophex.Supervisor))
  end

  test "accept() is spawned by supervisor" do
    Gophex.start("", "")
    assert is_pid(Process.whereis(:accept))
  end
end
