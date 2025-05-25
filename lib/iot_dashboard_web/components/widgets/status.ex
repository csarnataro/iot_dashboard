defmodule IotDashboardWeb.Widgets.Status do
  use IotDashboardWeb, :html

  def display(assigns) do
    value = assigns[:value]

    {css_color, text} =
      if value == "true", do: {"bg-green-600", "ON"}, else: {"bg-red-600", "OFF"}

    assigns =
      assigns
      |> assign(:color, css_color)
      |> assign(:label, text)

    ~H"""
    <div class={"w-full text-white grow flex items-center justify-center flex-col min-w-full w-full h-full rounded-lg px-2 #{@color}"  }>
      <%= @label %>
    </div>
    """
  end
end
