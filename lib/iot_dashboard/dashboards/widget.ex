defmodule IotDashboard.Dashboards.Widget do
  alias IotDashboard.Dashboards.WidgetOption
  use Ecto.Schema
  import Ecto.Changeset

  schema "widgets" do
    field(:type, :string)
    field(:value, :string)
    field(:width, :integer)
    field(:y, :integer)
    field(:x, :integer)
    field(:height, :integer)
    field(:properties, :string)
    field(:dashboard_id, :id)
    has_many(:options, WidgetOption, on_delete: :delete_all)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(widget, attrs) do
    widget
    |> cast(attrs, [:value, :y, :x, :width, :height, :type, :properties, :dashboard_id])
    |> cast_assoc(:options)
    |> validate_required([:y, :x, :width, :height, :type, :properties, :dashboard_id])
  end

  def option(nil, _option_name), do: ""

  def option(options, option_name) do
    options
    |> Enum.find(%{:value => "-"}, fn o -> o.name == option_name end)
    |> Map.get(:value)
  end
end
