defmodule IotDashboard.Dashboards.WidgetRegistry do
  alias IotDashboardWeb.Widgets.Status
  alias IotDashboardWeb.Widgets.NotAvailable
  alias IotDashboardWeb.Widgets.Switch
  alias IotDashboardWeb.Widgets.CircularProgress
  alias IotDashboardWeb.Widgets.Text
  alias IotDashboardWeb.Widgets.Led

  use IotDashboardWeb, :live_view

  def render_widget(assigns, widget) do
    widget_id = widget.id
    value = invariant(widget, :value, "--")
    data_type = invariant(widget, :data_type, "string")
    type = invariant(widget, :type, "text")
    options = widget.options

    get_func_component(type).(
      assigns
      |> assign(:widget_id, widget_id)
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

  def options_for_select do
    catalog()
    |> Enum.map(fn {key, value} -> {value[:label], to_string(key)} end)
  end

  def catalog do
    %{
      text: %{
        defaults: %{
          width: 2,
          height: 2,
          name: "My Text"
        },
        label: "Text"
        # options: %{
        #   type: :string
        # }
      },
      status: %{
        defaults: %{
          width: 2,
          height: 2,
          name: "My Status"
        },
        label: "Status"
        # options: %{
        #   off_color: "#FF0000",
        #   on_color: "#00FF00"
        # }
      },
      chart: %{
        defaults: %{
          width: 4,
          height: 3,
          name: "My Chart"
        },
        label: "Chart"
        # options: %{
        #   name: "Chart"
        # }
      },
      switch: %{
        defaults: %{
          width: 2,
          height: 1,
          name: "My Switch"
        },
        label: "Switch"
        # options: %{
        #   name: "Switch"
        # }
      }
    }
  end
end
