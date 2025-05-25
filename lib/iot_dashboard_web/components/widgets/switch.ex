defmodule IotDashboardWeb.Widgets.Switch do
  use IotDashboardWeb, :html

  defp negate(value) do
    if value == "false", do: "true", else: "false"
  end

  def display(assigns) do
    value = assigns.value
    checked = if value == "true", do: %{checked: value}, else: %{}

    assigns =
      assigns
      |> assign(:checked, checked)

    ~H"""
    <label class="switch">
      <input
        type="checkbox"
        phx-click={
          JS.push("update_value", value: %{widget_id: @widget_id, widget_value: negate(@value)})
        }
        {@checked}
      />
      <span class="slider round"></span>
    </label>
    """
  end
end
