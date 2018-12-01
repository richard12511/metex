defmodule PingPong.Pong do
  def loop do
    receive do
      {sender_pid, :ping} ->
        IO.puts("Pong")
        send(sender_pid, {self, :pong})
      _ -> IO.puts("unknown message in pong")
      loop()
    end
  end
end