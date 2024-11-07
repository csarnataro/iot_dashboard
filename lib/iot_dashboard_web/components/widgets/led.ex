defmodule IotDashboardWeb.Widgets.Led do
  use IotDashboardWeb, :html

  @color_on "red"
  @color_off "lightgray"
  # I could have called it `render` but I wanted to avoid confusion
  # with the render method of live components
  def display(assigns) do
    value = assigns[:value]

    color = if value == "true", do: @color_on, else: @color_off
    beam_fill = if value == "true", do: color, else: "none"

    assigns =
      assigns
      |> assign(:color, color)
      |> assign(:beam_fill, beam_fill)

    ~H"""
    <div class="">
      <svg class="mx-auto flex-1" height="50px" width="50px">
        <g>
          <circle cy="50%" cx="50%" r="23" stroke-dasharray="1, 7" stroke={@beam_fill} fill="none">
          </circle>
          <circle r="18" cy="50%" cx="50%" fill={@color}></circle>
        </g>
      </svg>
    </div>
    """
  end
end
