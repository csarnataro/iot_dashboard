defmodule IotDashboard.Dashboards.WidgetOption do
  use Ecto.Schema
  import Ecto.Changeset

  schema "widget_options" do
    field(:name, :string)
    field(:value, :string)
    field(:widget_id, :id)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(widget_option, attrs) do
    widget_option
    |> cast(attrs, [:value, :name])
    |> validate_required([:name, :value])
  end
end
