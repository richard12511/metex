defmodule Metex.Worker do
  use GenServer
  @name :metex_worker

  #api methods
  def start_link(), do: GenServer.start_link(__MODULE__, [], name: @name)
  def get_temperature(location), do: GenServer.call(@name, {:location, location})
  def get_stats, do: GenServer.call(@name, :get_stats)
  def reset_stats, do: GenServer.cast(@name, :reset_stats)

  #server methods
  def init(_), do: {:ok, Map.new}

  def handle_call(:get_stats, _from, stats), do: {:reply, stats, stats}

  def handle_call({:location, location}, _from, stats) do
    case temperature_of(location) do
      {:ok, temp} -> {:reply, "#{temp}C", update_stats(stats, location)}
      :error ->  {:reply, :error, stats}
    end
  end

  def handle_cast(:reset_stats, _stats), do: {:noreply, %{}}

  defp temperature_of(location) do
    location |> url_for |> HTTPoison.get |> parse_response
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp apikey do
    "a5d3c9e341baf8446f77dd9bef74d825"
  end

  defp update_stats(old_stats, location) do
    case Map.has_key?(old_stats, location) do
      true -> Map.update!(old_stats, location, fn count -> count + 1 end)
      _ -> Map.put_new(old_stats, location, 1)
    end
  end

end