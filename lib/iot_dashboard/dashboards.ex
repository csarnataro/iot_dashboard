defmodule IotDashboard.Dashboards do
  use GenServer

  @initial_dashboard %{
    widgets: [
      %{
        :id => "1",
        :x => 0,
        :y => 0,
        :width => 2,
        :height => 2,
        :type => "text",
        :properties => ["temperature"],
        :options => %{
          "title" => "Temperatura 1"
        }
      },
      %{
        :id => "2",
        :data_type => "float",
        :x => 3,
        :y => 0,
        :type => "status",
        :width => 3,
        :height => 3,
        :value => nil,
        :properties => ["humidity"],
        :options => %{
          "title" => "Temp 2"
        }
      },
      %{
        :id => "3",
        :name => "humidity",
        :data_type => "float",
        :value => 3.4,
        :x => 6,
        :y => 0,
        :type => "text",
        :width => 3,
        :height => 3,
        :options => %{
          "title" => "Temp 3"
        }
      },
      %{
        :id => "4",
        :x => 9,
        :y => 0,
        :type => "text",
        :width => 4,
        :height => 3,
        :options => %{
          "title" => "Temp 4"
        }
      },
      %{
        :id => "s3",
        :x => 1,
        :y => 4,
        :type => "switch",
        :width => 4,
        :height => 3,
        "value" => "true",
        :options => %{}
      }
    ]
  }

  ## Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts ++ [name: __MODULE__])
  end

  def get_dashboard(dashboard_id) do
    GenServer.call(__MODULE__, {:get_dashboard, dashboard_id})
  end

  def add_widget(dashboard_id, widget) do
    GenServer.cast(__MODULE__, {:add_widget, dashboard_id, widget})
  end

  def move_widget(_dashboard_id, widget_id, widget_position) do
    GenServer.call(__MODULE__, {:move_widget, widget_id, widget_position})
  end

  def update_options(widget_id, option_name, option_value) do
    GenServer.call(__MODULE__, {:update_options, widget_id, option_name, option_value})
  end

  def delete_widget(widget_id) do
    GenServer.call(__MODULE__, {:delete_widget, widget_id})
  end

  def create_widget(type, name, property) do
    GenServer.call(__MODULE__, {:create_widget, type, name, property})
  end

  def update_all_widgets(widgets) do
    GenServer.cast(__MODULE__, {:update_all_widgets, widgets})
  end

  def write(key, val) do
    GenServer.cast(__MODULE__, {:write, key, val})
  end

  def read(key) do
    GenServer.call(__MODULE__, {:read, key})
  end

  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  def clear() do
    GenServer.cast(__MODULE__, {:clear})
  end

  def exists?(key) do
    GenServer.call(__MODULE__, {:exists?, key})
  end

  ## Server API

  def init(_args) do
    {:ok, @initial_dashboard}
  end

  def handle_call({:get_dashboard, _dashboard_id}, _from, dashboard_store) do
    {:reply, dashboard_store, dashboard_store}
  end

  def handle_call({:read, key}, _from, cache) do
    {:reply, Map.fetch(cache, key), cache}
  end

  def handle_call({:exists?, key}, _from, cache) do
    {:reply, Map.has_key?(cache, key), cache}
  end

  def handle_call(
        {:move_widget, widget_id, {:ok, widget_position}},
        _from,
        %{widgets: widgets} = cache
      ) do
    updated_widget_idx =
      Enum.find_index(widgets, fn w -> w[:id] == widget_id end)

    updated_widget =
      widgets
      |> Enum.at(updated_widget_idx)
      |> Map.put(:x, widget_position["x"])
      |> Map.put(:y, widget_position["y"])
      |> Map.put(:width, widget_position["width"])
      |> Map.put(:height, widget_position["height"])

    updated_widgets =
      widgets
      |> List.replace_at(updated_widget_idx, updated_widget)

    new_dashboard = %{cache | widgets: updated_widgets}
    {:reply, new_dashboard, new_dashboard}
  end

  def handle_call({:create_widget, type, name, property}, _from, %{widgets: widgets} = cache) do
    new_widget = %{
      :id => :crypto.strong_rand_bytes(10) |> Base.encode32(),
      :x => 0,
      :y => 0,
      :width => 2,
      :height => 2,
      :type => type,
      :properties => [property],
      :options => %{
        "title" => name
      }
    }

    updated_widgets = [new_widget | widgets]

    new_dashboard = %{cache | widgets: updated_widgets}
    {:reply, new_dashboard, new_dashboard}
  end

  def handle_call({:delete_widget, widget_id}, _from, %{widgets: widgets} = cache) do
    updated_widgets =
      widgets
      |> Enum.filter(fn w -> w[:id] !== widget_id end)

    new_dashboard = %{cache | widgets: updated_widgets}
    {:reply, new_dashboard, new_dashboard}
  end

  def handle_call(
        {:update_options, widget_id, name, value},
        _from,
        %{widgets: widgets} = cache
      ) do
    updated_widget_idx =
      Enum.find_index(widgets, fn w -> w[:id] == widget_id end)

    updated_widget =
      widgets
      |> Enum.at(updated_widget_idx)

    updated_options = Map.put(updated_widget[:options], name, value)

    updated_widget =
      updated_widget
      |> Map.put(:options, updated_options)

    updated_widgets =
      widgets
      |> List.replace_at(updated_widget_idx, updated_widget)

    new_dashboard = %{cache | widgets: updated_widgets}
    {:reply, new_dashboard, new_dashboard}
  end

  def handle_cast({:update_all_widgets, widgets}, cache) do
    {:noreply, Map.put(cache, :widgets, widgets)}
  end

  def handle_cast({:write, key, val}, cache) do
    {:noreply, Map.put(cache, key, val)}
  end

  def handle_cast({:delete, key}, cache) do
    {:noreply, Map.delete(cache, key)}
  end

  def handle_cast({:clear}, _cache) do
    {:noreply, %{}}
  end
end
