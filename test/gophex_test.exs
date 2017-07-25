defmodule GophexTest do
  use ExUnit.Case, async: true
  doctest Gophex

  test "Main process is spawned" do
    assert is_pid(Process.whereis(:main))
  end
end
