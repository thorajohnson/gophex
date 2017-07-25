defmodule GophexTest do
  use ExUnit.Case, async: true
  doctest Gophex

  test "Main process is spawned" do
    Gophex.start("", "")
    assert is_pid(Process.whereis(:main))
  end
end
