defmodule IotDashboard.WidgetRegistry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register_widget(widget_id) do
    GenServer.cast(__MODULE__, {:set, widget_id})
  end

  # def fetch(slug, default_value_function) do
  #   case get(slug) do
  #     {:not_found} -> set(slug, default_value_function.())
  #     {:found, result} -> result
  #   end
  # end

  # defp get(slug) do
  #   case GenServer.call(__MODULE__, {:get, slug}) do
  #     [] -> {:not_found}
  #     [{_slug, result}] -> {:found, result}
  #   end
  # end

  # def set(slug, value) do
  #   GenServer.call(__MODULE__, {:set, slug, value})
  # end

  # GenServer callbacks

  # def handle_call({:get, slug}, _from, state) do
  #   %{ets_table_name: ets_table_name} = state
  #   result = :ets.lookup(ets_table_name, slug)
  #   {:reply, result, state}
  # end

  def handle_cast({:set, widget_id}, state) do
    {:noreply, MapSet.put(state, widget_id)}
  end

  def init(_args) do
    {:ok, MapSet.new()}
  end
end
