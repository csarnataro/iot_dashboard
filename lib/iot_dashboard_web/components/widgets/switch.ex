defmodule IotDashboardWeb.Widgets.Switch do
  use IotDashboardWeb, :html

  def display(assigns) do
    checked = "checked"

    ~H"""
    <label class="switch">
      <input type="checkbox" @checked />
      <span class="slider round"></span>
    </label>
    """
  end
end
