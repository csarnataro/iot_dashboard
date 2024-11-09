defmodule IotDashboardWeb.Widgets.CircularProgress do
  use IotDashboardWeb, :html

  @doc """
  Renders a progress bar for an ongoing operation.

  ## Examples

      <.progress_bar hidden=false progress=15 />
      <.progress_bar hidden=false progress=20 message="Activating system ..." />
      <.progress_bar hidden=false class="cool-bar" />
  """

  attr :class, :string, default: nil

  # @color "#60e6a8"
  @color "#16a34a"

  def display(assigns) do
    numeric_value =
      case Integer.parse("#{assigns.value}") do
        {value, _} -> value
        _ -> -1
      end

    svg_params =
      case numeric_value do
        -1 ->
          %{stroke: "transparent", offset: "", label: "--"}

        v when v in 1..100 ->
          offset = "#{v} #{100 - v}"
          %{stroke: @color, offset: offset, label: "#{v}%"}

        _ ->
          %{
            stroke: @color,
            offset: "100 0",
            label: "#{numeric_value}%",
            label_color: "red"
          }
      end

    assigns =
      assigns
      |> assign(:value, numeric_value)
      |> assign(:svg_params, svg_params)

    ~H"""
    <div class={"h-full w-full p-0 #{@class}"}>
      <svg
        viewBox="0 0 120 120"
        xmlns="http://www.w3.org/2000/svg"
        preserveAspectRatio="xMinYMin meet"
      >
        <circle cx="60" cy="60" r="40" fill="transparent" stroke="#e0e0e0" stroke-width="10px" />
        <circle
          cx="60"
          cy="60"
          r="40"
          fill="transparent"
          stroke={@svg_params[:stroke]}
          stroke-width="8px"
          stroke-linecap="round"
          pathLength="100"
          stroke-dasharray={@svg_params[:offset]}
          stroke-dashoffset="-75"
        />
        <text
          x="50%"
          y="55%"
          text-anchor="middle"
          alignment-baseline="middle"
          fill={@svg_params[:label_color]}
        >
          <%= @svg_params[:label] %>
        </text>
      </svg>
    </div>
    """
  end
end
