defmodule IotDashboardWeb.DashboardLive do
  # use Phoenix.LiveView

  import IotDashboardWeb.Modals

  alias IotDashboardWeb.Widgets.Status
  alias IotDashboard.Mqtt.Client, as: MqttClient
  alias IotDashboard.Dashboards
  alias IotDashboardWeb.Widgets.NotAvailable
  alias IotDashboardWeb.Widgets.Switch
  alias IotDashboardWeb.Widgets.CircularProgress
  alias IotDashboardWeb.Widgets.Text
  alias IotDashboardWeb.Widgets.Led
  use IotDashboardWeb, :live_view

  def mount(_params, _session, socket) do
    dashboard = Dashboards.get_dashboard(1)

    # for widget <- if(dashboard != nil, do: dashboard.widgets, else: []) do
    #   WidgetRegistry.register_widget(widget.id)
    # end

    case connected?(socket) do
      true ->
        MqttClient.start()
        MqttClient.subscribe(MqttClient.mqtt_updates_event())

      false ->
        nil
    end

    widgets = dashboard.widgets

    socket =
      socket
      |> assign(locked: true)
      |> assign(widgets: widgets)
      |> assign(dashboard_id: dashboard.id)
      |> assign(dashboard: dashboard)
      |> assign(dashboard_name: dashboard.title)

    {:ok, socket}
  end

  def render(assigns) do
    # form_fields = %{"my_field" => "what"}

    assigns =
      assigns
      # |> assign(settings_form: to_form(form_fields))
      # |> assign(:create_form, %{"my_field" => %{"value" => "what", "name" => "which"}})
      |> assign_new(:locked, fn ->
        if Map.has_key?(assigns, :locked), do: assigns[:locked], else: true
      end)

    # if widget.min_width, do: widget.min_width, else: 2}
    # if widget.min_height, do: widget.min_height, else: 2}
    # if widget.max_width, do: widget.max_width, else: 6}
    # if widget.max_height, do: widget.max_height, else: 6}

    ~H"""
    <div>
      <div class="flex justify-between w-full pb-1">
        <div><%= @dashboard_name %></div>
        <nav aria-label="Toolbar" class="xt-list xt-list-2">
          <button
            title="Click to add a new widget"
            class="rounded-lg border bg-white z-10 p-1"
            phx-click={:show_new_widget_modal}
          >
            <Heroicons.icon name="plus" type="solid" class="h-5 w-5 text-gray-400" />
          </button>

          <button
            title="Click to lock/unlock widgets position"
            class="rounded-lg border bg-white z-10 p-1"
            phx-click={:toggle_lock}
            phx-value-locked={if @locked, do: "true", else: "false"}
          >
            <Heroicons.icon
              name={if @locked, do: "lock-closed", else: "lock-open"}
              type="solid"
              class="h-5 w-5 text-gray-400"
            />
          </button>
        </nav>
      </div>

      <div>
        <div
          id="GridStackHook"
          class="grid-stack bg-gray-100 gs-12 rounded rounded-xl mb-8 min-h-[80vh]"
          phx-hook="GridStackHook"
          gs-static={if @locked, do: "true", else: "false"}
        >
          <div
            :for={widget <- @widgets}
            id={"w_#{widget.id}"}
            class="grid-stack-item"
            gs-locked="yes"
            gs-x={widget.x}
            gs-y={widget.y}
            gs-w={widget.width}
            gs-h={widget.height}
            gs-min-w={1}
            gs-min-h={1}
            gs-max-w={6}
            gs-max-h={6}
          >
            <div class={"grid-stack-item-content border rounded-lg bg-white pt-0 pb-2 h-100 flex flex-col #{if @locked, do: "blocked_widget"}"}>
              <div class={"card-header justify-between flex shrink pl-2 pr-1 #{if @locked, do: "cursor-auto", else: "cursor-pointer" }"}>
                <span class={"relative text-sm select-none cursor-pointer transition-all #{if @locked, do: "opacity-0 left-[-20px]", else: "visible left-0" }"}>
                  :::
                </span>
                <span
                  title={widget.options["title"]}
                  class={"relative text-xs p-1 text-ellipsis text-nowrap overflow-hidden w-full select-none transition-all #{if @locked, do: "left-[-15px]", else: "left-[5px]" }"}
                >
                  <%= widget.options["title"] %>
                </span>
                <button
                  class="w-5 h-5 mt-1 settings-button text-gray-500 p-1 select-none"
                  phx-click={:show_settings}
                  phx-value-widget_id={widget.id}
                >
                </button>
              </div>
              <div class="grow flex justify-center flex-col items-center h-full px-2 overflow-hidden">
                <%= render_widget(assigns, widget) %>
              </div>
            </div>
          </div>
        </div>
      </div>
      <%= if assigns[:show_new_widget_modal] do %>
        <.new_widget_modal dashboard_id={@dashboard_id} />
      <% end %>
      <%= if assigns[:show_settings_modal] do %>
        <.settings_modal widget={@selected_widget} form={@selected_widget_form} />
      <% end %>

      <details>
        <summary class="fixed overflow-hidden right-1 bottom-1 bg-green-300 z-10 p-2 rounded">
          <span class="text-serif">Inspect</span>
        </summary>
        <pre
          id="details_box"
          class="fixed block text-xs overflow-auto right-1 w-96 h-[50vh] rounded bottom-12 bg-yellow-100 z-10 p-2"
        >
        <pre><%= inspect(@widgets, pretty: true) %></pre>
      </pre>
      </details>
    </div>
    """
  end

  def handle_event("widget:move", %{"positions" => new_positions}, socket) do
    "w_" <> widget_id = Map.keys(new_positions) |> List.first()
    new_positions = Map.fetch(new_positions, "w_" <> widget_id)

    updated_dashboard = Dashboards.move_widget("", widget_id, new_positions)

    {
      :noreply,
      assign(socket, :widgets, updated_dashboard.widgets)
    }
  end

  def handle_event("show_new_widget_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_new_widget_modal, true)}
  end

  def handle_event("hide_new_widget_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_new_widget_modal, false)}
  end

  def handle_event(
        "add_new_widget",
        params,
        socket
      ) do
    case Dashboards.create_widget_with_defaults(params) do
      {:error, rest} ->
        IO.puts("******** BEGIN: dashboard_live:186 ********")
        dbg(rest)
        IO.puts("********   END: dashboard_live:186 ********")

        {
          :noreply,
          socket
        }

      _ ->
        Dashboards.get_dashboard(socket.assigns.dashboard_id)

        updated_dashboard = Dashboards.get_dashboard(socket.assigns.dashboard_id)

        {
          :noreply,
          assign(socket, :widgets, updated_dashboard.widgets)
        }
    end
  end

  def handle_event("delete_widget", %{"widget_id" => widget_id}, socket) do
    updated_dashboard = Dashboards.delete_widget(widget_id)

    {
      :noreply,
      socket
      |> assign(:show_settings_modal, false)
      |> assign(:widgets, updated_dashboard.widgets)
    }
  end

  def handle_event("show_settings", %{"widget_id" => widget_id}, socket) do
    case Integer.parse(widget_id) do
      {widget_id, _} ->
        widget = Dashboards.get_widget!(widget_id)
        IO.puts("******** BEGIN: dashboard_live:225 ********")
        dbg(widget_id)
        IO.puts("********   END: dashboard_live:225 ********")

        form =
          to_form(%{
            "id" => widget.id,
            "title" => widget.options["title"],
            "property" => widget.properties
          })

        {:noreply,
         socket
         |> assign(:show_settings_modal, true)
         |> assign(:selected_widget_form, form)
         |> assign(
           :selected_widget,
           widget
         )}

      :error ->
        {:noreply, socket}
    end
  end

  def handle_event("hide_settings_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_settings_modal, false)
     |> assign(:selected_widget, nil)}
  end

  def handle_event("toggle_lock", %{"locked" => "true"}, socket) do
    {:noreply, socket |> assign(locked: false)}
  end

  def handle_event("toggle_lock", %{"locked" => "false"}, socket) do
    dashboard = Dashboards.get_dashboard("dashboard_id")

    {:noreply,
     socket
     |> assign(locked: true)
     |> assign(:widgets, dashboard.widgets)}
  end

  def handle_event(
        "save_settings",
        params,
        socket
      ) do
    IO.puts("******** BEGIN: dashboard_live:251 ********")
    IO.inspect(socket.assigns.dashboard_id, pretty: true)
    IO.puts("********   END: dashboard_live:251 ********")

    %{"widget_id" => id, "title" => title, "property" => property} = params

    Dashboards.update_widget(id, %{id: id, options: %{title: title}, properties: property})

    dashboard = Dashboards.get_dashboard!(socket.assigns.dashboard_id)

    {
      :noreply,
      socket
      |> assign(:widgets, dashboard.widgets)
      |> assign(:show_settings_modal, false)
    }
  end

  # do nothing if the dashboard is locked, to avoid JS errors!!!
  def handle_info({:new_mqtt_message, message}, %{assigns: %{locked: false}} = socket) do
    case socket.assigns.dashboard do
      dashboard when dashboard !== nil ->
        Dashboards.update_last_value(dashboard.id, message["property"], message["value"])

      _ ->
        nil
    end

    {:noreply, socket}
  end

  # update values only if dashboard is locked
  def handle_info(
        {:new_mqtt_message, message},
        %{assigns: %{locked: true}} = socket
      ) do
    case socket.assigns.dashboard do
      dashboard when dashboard !== nil ->
        Dashboards.update_last_value(dashboard.id, message["property"], message["value"])
        updated_dashboard = Dashboards.get_dashboard(dashboard.id)

        {
          :noreply,
          assign(socket, :widgets, updated_dashboard.widgets)
        }

      _ ->
        nil
        {:noreply, socket}
    end
  end

  defp render_widget(assigns, widget) do
    value = invariant(widget, :value, "--")
    data_type = invariant(widget, :data_type, "string")
    type = invariant(widget, :type, "text")
    options = widget.options

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
  defp get_func_component("status"), do: &Status.display/1
  defp get_func_component("circular_progress"), do: &CircularProgress.display/1
  defp get_func_component(_), do: &NotAvailable.display/1
end
