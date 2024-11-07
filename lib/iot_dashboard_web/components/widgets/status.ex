defmodule IotDashboardWeb.Widgets.Status do
  use IotDashboardWeb, :html

  @color_on "red"
  @color_off "lightgray"
  # I could have called it `render` but I wanted to avoid confusion
  # with the render method of live components
  def display(assigns) do
    # value = if Map.has_key?(assigns, :options), do: assigns[:options]["value"]
    value = assigns[:value]

    # color = if value == "true", do: @color_on, else: @color_off
    # beam_fill = if value == "true", do: color, else: "none"

    {css_color, text} =
      if value == "true", do: {"bg-green-600", "ON"}, else: {"bg-red-600", "OFF"}

    assigns =
      assigns
      |> assign(:color, css_color)
      |> assign(:label, text)

    # |> assign(:beam_fill, beam_fill)

    ~H"""
    <div class={"w-full text-white grow flex items-center justify-center flex-col min-w-full w-full h-full rounded-lg px-2 #{@color}"  }>
      <%= @label %>
      <%!-- <svg class="mx-auto flex-1" height="50px" width="50px">
        <g>
          <circle cy="50%" cx="50%" r="23" stroke-dasharray="1, 7" stroke={@beam_fill} fill="none">
          </circle>
          <circle r="18" cy="50%" cx="50%" fill={@color}></circle>
        </g>
      </svg> --%>
    </div>
    """
  end
end
