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
      socket
      |> assign(locked: true)
      |> stream(:widgets, widgets, dom_id: &"w_#{&1.id}")

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

    IO.puts("******** BEGIN: dashboard_live:52 ********")
    IO.inspect(Map.has_key?(assigns, :locked), pretty: true)
    IO.inspect(assigns[:locked], pretty: true)
    IO.puts("********   END: dashboard_live:52 ********")

    assigns =
      assigns
      |> assign_new(:locked, fn ->
        if Map.has_key?(assigns, :locked), do: assigns[:locked], else: true
      end)

    ~H"""
    <div>
      <%= assigns[:locked] %>
      <hr />
      <button
        phx-click={:toggle_lock}
        phx-value-locked={if @locked, do: "true", else: "false"}
        class="rounded bg-blue-600 p-1 text-white"
      >
        <%= if @locked, do: "Unlock", else: "Lock" %>
      </button>

      <div class="h-screen bg-gray-100 rounded rounded-xl p-4">
        <div
          id="GridStackHook"
          class="grid-stack bg-gray-100 gs-12"
          phx-hook="GridStackHook"
          phx-update="stream"
          gs-static={if @locked, do: "true", else: "false"}
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
              <div class={"card-header justify-between flex shrink pl-2 pr-1 #{if @locked, do: "cursor-auto", else: "cursor-pointer" }"}>
                <span class="text-xs p-1 text-ellipsis text-nowrap overflow-hidden w-full select-none">
                  <%= assigns[:locked] %><%= widget[:options]["title"] %>
                </span>
                <span class="text-gray-500 p-1 select-none">
                  <Heroicons.icon name="cog-6-tooth" type="outline" class="h-4 w-4 text-gray-800" />
                </span>
              </div>
              <div class="grow flex justify-center flex-col h-full mx-auto px-2">
                <%= render_widget(assigns, widget) %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("widget:move", %{"positions" => new_positions}, socket) do
    "w_" <> widget_id = Map.keys(new_positions) |> List.first()
    new_positions = Map.fetch(new_positions, "w_" <> widget_id)
    Dashboards.move_widget("", widget_id, new_positions)
    {:noreply, socket}
  end

  def handle_event("toggle_lock", %{"locked" => "true"}, socket) do
    IO.puts("******** BEGIN: dashboard_live:144 ********")
    IO.inspect("NOW IS TRUE", pretty: true)
    IO.puts("********   END: dashboard_live:144 ********")

    {:noreply, socket |> assign(locked: false)}
  end

  def handle_event("toggle_lock", %{"locked" => "false"}, socket) do
    IO.puts("******** BEGIN: dashboard_live:144 ********")
    IO.inspect("NOW IS FALSE", pretty: true)
    IO.puts("********   END: dashboard_live:144 ********")

    {:noreply, socket |> assign(locked: true)}
  end

  # do nothing if the dashboard is locked, to avoid JS errors!!!
  # def handle_info({:new_mqtt_message, _}, %{:assigns => %{locked: "false"}} = socket) do
  #   {:noreply, socket}
  # end

  # update values if dashboard is locked
  def handle_info({:new_mqtt_message, message}, socket) do
    IO.puts("******** BEGIN: dashboard_live:143 ********")
    IO.inspect(message, pretty: true)
    IO.puts("********   END: dashboard_live:143 ********")

    {:ok, widgets} =
      Dashboards.get_dashboard("dashboard_id")
      |> Map.fetch(:widgets)

    widget_to_update =
      Enum.find(
        widgets,
        fn w -> if w.id == message["id"], do: w end
      )

    widget_to_update = Map.put(widget_to_update, :value, message["value"])

    {:noreply,
     socket
     |> stream_insert(:widgets, widget_to_update)}
  end

  defp render_widget(assigns, widget) do
    IO.puts("******** BEGIN: dashboard_live:161 ********")
    IO.inspect(widget, pretty: true)
    IO.puts("********   END: dashboard_live:161 ********")
    value = invariant(widget, :value, "N/A")
    data_type = invariant(widget, :data_type, "string")
    type = invariant(widget, :type, "text")
    options = widget[:options]

    get_func_component(type).(
      assigns
      |> assign(:value, value)
      |> assign(:data_type, data_type)
      |> assign(:options, options)
    )
  end

  defp invariant(map, key, default) do
    if Map.has_key?(map, key) do
      invariant(Map.fetch!(map, key), default)
    else
      default
    end
  end

  defp invariant(var, default) do
    if var == "" or var == nil, do: default, else: var
  end

  defp get_func_component("text"), do: &Text.display/1
  defp get_func_component("led"), do: &Led.display/1
  defp get_func_component("switch"), do: &Switch.display/1
  defp get_func_component("circular_progress"), do: &CircularProgress.display/1
  defp get_func_component(_), do: &NotAvailable.display/1
end
