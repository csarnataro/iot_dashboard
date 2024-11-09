defmodule IotDashboard.Widget do
  @enforce_keys [:id]
  defstruct [
    :id,
    :x,
    :y,
    :width,
    :height,
    :value,
    :properties,
    type: "text",
    options: %{},
    data_type: "string"
  ]
end
