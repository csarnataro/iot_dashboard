defmodule IotDashboardWeb.Widgets.NotAvailable do
  use IotDashboardWeb, :html

  # I could have called it `render` but I wanted to avoid confusion
  # with the render method of live components
  def display(assigns) do
    ~H"""
    <div>
      <span>Widget not available</span>
    </div>
    """
  end
end
