defmodule IotDashboard.DashboardsOrig do
  use GenServer

  @initial_dashboard %{
    widgets: [
      %{
        :id => "1",
        :y => 0,
        :x => 0,
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
        :data_type => "float",
        :value => 3.4,
        :x => 6,
        :y => 0,
        :type => "circular_progress",
        :properties => ["humidity"],
        :width => 3,
        :value => 35,
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
        :value => "true",
        :options => %{}
      }
    ]
  }

  ## Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts ++ [name: __MODULE__])
  end

  def update_last_value(property_name, value) do
    GenServer.call(__MODULE__, {:update_last_value, property_name, value})
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

  def update_widget_fields(widget_id, fields) do
    GenServer.call(__MODULE__, {:update_widget_fields, widget_id, fields})
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

  def handle_call({:get_dashboard, _dashboard_id}, _from, dashboard) do
    {:reply, dashboard, dashboard}
  end

  def handle_call({:read, key}, _from, dashboard) do
    {:reply, Map.fetch(dashboard, key), dashboard}
  end

  def handle_call({:exists?, key}, _from, dashboard) do
    {:reply, Map.has_key?(dashboard, key), dashboard}
  end

  def handle_call({:update_last_value, property_name, value}, _from, dashboard) do
    non_updated_widgets =
      dashboard.widgets
      |> Enum.filter(fn w -> !has_property?(w, property_name) end)

    updated_widgets =
      dashboard.widgets
      |> Enum.filter(fn w -> has_property?(w, property_name) end)
      |> Enum.map(fn w -> Map.put(w, :value, value) end)

    all_widgets = updated_widgets ++ non_updated_widgets

    new_dashboard = %{dashboard | widgets: all_widgets}
    {:reply, new_dashboard, new_dashboard}
  end

  def handle_call(
        {:move_widget, widget_id, {:ok, widget_position}},
        _from,
        %{widgets: widgets} = dashboard
      ) do
    updated_widget_idx = find_widget_index(widgets, widget_id)

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

    new_dashboard = %{dashboard | widgets: updated_widgets}
    {:reply, new_dashboard, new_dashboard}
  end

  def handle_call({:create_widget, type, name, property}, _from, %{widgets: widgets} = dashboard) do
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

    new_dashboard = %{dashboard | widgets: updated_widgets}
    {:reply, new_dashboard, new_dashboard}
  end

  def handle_call({:delete_widget, widget_id}, _from, %{widgets: widgets} = dashboard) do
    updated_widgets =
      widgets
      |> Enum.filter(fn w -> w.id !== widget_id end)

    new_dashboard = %{dashboard | widgets: updated_widgets}
    {:reply, new_dashboard, new_dashboard}
  end

  def handle_call(
        {:update_widget_fields, widget_id, fields},
        _from,
        %{widgets: widgets} = dashboard
      ) do
    widget_idx = find_widget_index(widgets, widget_id)

    updated_widget =
      widgets
      |> Enum.at(widget_idx)
      |> Map.merge(fields)

    IO.puts("******** BEGIN: Dashboards:224 ********")
    IO.inspect(updated_widget, pretty: true)
    IO.puts("********   END: Dashboards:224 ********")

    updated_widgets =
      widgets
      |> List.replace_at(widget_idx, updated_widget)

    new_dashboard = %{dashboard | widgets: updated_widgets}
    {:reply, new_dashboard, new_dashboard}
  end

  def handle_call(
        {:update_options, widget_id, name, value},
        _from,
        %{widgets: widgets} = dashboard
      ) do
    updated_widget_idx = find_widget_index(widgets, widget_id)

    updated_widget =
      widgets
      |> Enum.at(updated_widget_idx)

    updated_options = Map.put(updated_widget.options, name, value)

    updated_widget =
      updated_widget
      |> Map.put(:options, updated_options)

    updated_widgets =
      widgets
      |> List.replace_at(updated_widget_idx, updated_widget)

    new_dashboard = %{dashboard | widgets: updated_widgets}
    {:reply, new_dashboard, new_dashboard}
  end

  def handle_cast({:update_all_widgets, widgets}, dashboard) do
    {:noreply, Map.put(dashboard, :widgets, widgets)}
  end

  def handle_cast({:write, key, val}, dashboard) do
    {:noreply, Map.put(dashboard, key, val)}
  end

  def handle_cast({:delete, key}, dashboard) do
    {:noreply, Map.delete(dashboard, key)}
  end

  def handle_cast({:clear}, _dashboard) do
    {:noreply, %{}}
  end

  def has_property?(nil, nil), do: false
  def has_property?(nil, _), do: false
  def has_property?(_, nil), do: false

  def has_property?(w, property_name) do
    # IO.puts("******** BEGIN: Dashboards:271 ********")
    # IO.inspect(w[:properties], pretty: true)
    # IO.inspect(Map.has_key?(w, :properties), pretty: true)
    # IO.inspect(is_list(w[:properties]), pretty: true)
    # IO.inspect(Enum.member?(w[:properties], property_name), pretty: true)
    # IO.puts("********   END: Dashboards:271 ********")

    case w.properties do
      properties when properties !== nil ->
        is_list(properties) && Enum.member?(properties, property_name)

      nil ->
        false
    end
  end

  defp find_widget_index(widgets, widget_id) do
    Enum.find_index(widgets, fn w -> w.id == widget_id end)
  end
end
