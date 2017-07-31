defmodule Gophex.GophexAgentTest do
  use ExUnit.Case, async: false

  test "Main process is spawned"  do
    #Gophex.Worker.spawn_main(:main)
    Gophex.Agent.start_link({})
    main_pid = Process.whereis(:main)
    assert is_pid(main_pid)
    #Process.exit(main_pid, :kill)
  end
end
