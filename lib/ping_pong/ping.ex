defmodule PingPong.Ping do
  def loop do
    receive do
      {sender_pid, :pong} ->
        IO.puts("Ping")
        send(sender_pid, {self, :ping})
      _ -> IO.puts "unkown message"
      loop()
    end
  end
end