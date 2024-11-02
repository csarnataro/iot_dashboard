defmodule IotDashboardWeb.DashboardLive do
  # use Phoenix.LiveView

  alias IotDashboard.WidgetRegistry
  alias IotDashboard.Mqtt.Client, as: MqttClient
  alias IotDashboard.Dashboards
  alias IotDashboardWeb.Widgets.NotAvailable
  alias IotDashboardWeb.Widgets.Switch
  alias IotDashboardWeb.Widgets.CircularProgress
  alias IotDashboardWeb.Widgets.Text
  alias IotDashboardWeb.Widgets.Led
  use IotDashboardWeb, :live_view

  @topic "mqtt_updates"

  def mount(_params, _session, socket) do
    dashboard = Dashboards.get_dashboard("dashboard_id")

    for widget <- if(dashboard != nil, do: dashboard.widgets, else: []) do
      WidgetRegistry.register_widget(widget.id)
    end

    case connected?(socket) do
      true ->
        MqttClient.start()
        MqttClient.subscribe(@topic)

      false ->
        nil
    end

    widgets = dashboard.widgets

    socket =
      stream(socket, :widgets, widgets, dom_id: &"w_#{&1.id}")

    {:ok, socket}
  end

  def render(assigns) do
    # gs-x={widget[:x]}
    # gs-y={widget[:y]}
    # gs-w={widget[:width]}
    # gs-h={widget[:height]}
    # gs-min-w={if widget[:min_width], do: widget[:min_width], else: 2}
    # gs-min-h={if widget[:min_height], do: widget[:min_height], else: 2}
    # gs-max-w={if widget[:max_width], do: widget[:max_width], else: 6}
    # gs-max-h={if widget[:max_height], do: widget[:max_height], else: 6}

    ~H"""
    <div>
      <div>
        <.form for={%{}} phx-submit="publish_to_mqtt" class="flex gap-2">
          <span>
            <.input
              type="select"
              class="border rounded"
              name="widget"
              value="1"
              options={[1, 2, 3, 4]}
            />
          </span>
          <span class="flex gap-2 items-center">
            Temperature: <.input type="text" name="temperature" value="" field={:temperature} />
          </span>
          <button class="rounded bg-blue-600 p-1 text-white">Send</button>
        </.form>
      </div>
      <div class="h-screen bg-gray-100 rounded rounded-xl p-4">
        <div
          id="GridStackHook"
          class="grid-stack bg-gray-100 gs-12"
          phx-hook="GridStackHook"
          phx-update="stream"
        >
          <div
            :for={{id, widget} <- @streams.widgets}
            id={id}
            class="grid-stack-item"
            gs-locked="yes"
            gs-x={widget[:x]}
            gs-y={widget[:y]}
            gs-w={widget[:width]}
            gs-h={widget[:height]}
            gs-min-w={if widget[:min_width], do: widget[:min_width], else: 2}
            gs-min-h={if widget[:min_height], do: widget[:min_height], else: 2}
            gs-max-w={if widget[:max_width], do: widget[:max_width], else: 6}
            gs-max-h={if widget[:max_height], do: widget[:max_height], else: 6}
          >
            <div class="grid-stack-item-content border rounded-lg bg-white pt-0 pb-4 h-100 flex flex-col">
              <div class="card-header cursor-pointer justify-between flex shrink pl-2 pr-1">
                <span class="text-xs p-1 text-ellipsis text-nowrap overflow-hidden w-full select-none">
                  <%= widget[:options]["title"] %>
                </span>
                <span class="text-gray-500 p-1 select-none">
                  <Heroicons.icon name="cog-6-tooth" type="outline" class="h-4 w-4 text-gray-800" />
                </span>
              </div>
              <div class="grow flex justify-center flex-col h-full mx-auto px-2">
                <%= render_widget(assigns, widget[:type], widget[:options]) %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("publish_to_mqtt", params, socket) do
    %{"widget" => id, "temperature" => temperature} = params
    temperature = invariant(temperature, "N/A")
    {:ok, payload} = Jason.encode(%{id: id, value: temperature})
    ExMQTT.publish(payload, "test/csarnataro/#{id}", 0)
    {:noreply, socket}
  end

  def handle_event("widget:move", %{"positions" => new_positions}, socket) do
    "w_" <> widget_id = Map.keys(new_positions) |> List.first()
    new_positions = Map.fetch(new_positions, "w_" <> widget_id)

    Dashboards.move_widget("", widget_id, new_positions)
    {:noreply, socket}
  end

  def handle_info({:new_mqtt_message, message}, socket) do
    dashboard = Dashboards.get_dashboard("dashboard_id")
    widgets = dashboard.widgets

    widget_to_update =
      Enum.find(
        widgets,
        fn w -> if w.id == message["id"], do: w end
      )

    widget_options = widget_to_update.options |> Map.merge(%{"value" => message["value"]})
    widget_to_update = %{widget_to_update | options: widget_options}

    {:noreply, socket |> stream_insert(:widgets, widget_to_update)}
    # {:noreply, socket}
  end

  defp render_widget(assigns, type, options) do
    get_func_component(type).(
      assigns
      |> assign(:options, options)
    )
  end

  defp invariant(var, def) do
    if var == "" or var == nil, do: def, else: var
  end

  defp get_func_component("text"), do: &Text.display/1
  defp get_func_component("led"), do: &Led.display/1
  defp get_func_component("switch"), do: &Switch.display/1
  defp get_func_component("circular_progress"), do: &CircularProgress.display/1
  defp get_func_component(_), do: &NotAvailable.display/1
end
