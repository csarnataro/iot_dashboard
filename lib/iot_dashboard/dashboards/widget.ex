defmodule IotDashboard.Dashboards.Widget do
  use Ecto.Schema
  import Ecto.Changeset

  schema "widgets" do
    field(:type, :string)
    field(:value, :string)
    field(:options, :map)
    field(:width, :integer)
    field(:y, :integer)
    field(:x, :integer)
    field(:height, :integer)
    field(:properties, :string)
    field(:dashboard_id, :id)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(widget, attrs) do
    widget
    |> cast(attrs, [:value, :y, :x, :width, :height, :type, :properties, :options])
    |> validate_required([:y, :x, :width, :height, :type, :properties, :options])
  end
end
