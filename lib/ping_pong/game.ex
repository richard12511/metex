defmodule PingPong.Game do
  def play do
    ping_pid = spawn(PingPong.Ping, :loop, [])
    pong_pid = spawn(PingPong.Pong, :loop, [])

    send(ping_pid, {pong_pid, :pong})
  end
end