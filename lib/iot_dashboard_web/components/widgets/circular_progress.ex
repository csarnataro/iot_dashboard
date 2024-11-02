defmodule IotDashboardWeb.Widgets.CircularProgress do
  use IotDashboardWeb, :html

  def display(assigns) do
    ~H"""
    <svg
      width="154"
      height="154"
      viewBox="-19.25 -19.25 192.5 192.5"
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      style="transform:rotate(-90deg)"
    >
      <circle
        r="67"
        cx="77"
        cy="77"
        fill="transparent"
        stroke="#e0e0e0"
        stroke-width="16px"
        stroke-dasharray="420.76px"
        stroke-dashoffset="0"
      >
      </circle>
      <circle
        r="67"
        cx="77"
        cy="77"
        stroke="#0ebeb2"
        stroke-width="10"
        stroke-linecap="round"
        stroke-dashoffset="164px"
        fill="transparent"
        stroke-dasharray="420.76px"
      >
      </circle>
      <text
        x="50px"
        y="92px"
        fill="#6bdba7"
        font-size="52px"
        font-weight="bold"
        style="transform:rotate(90deg) translate(0px, -150px)"
      >
        <%= @options.value %>
      </text>
    </svg>
    """
  end
end
