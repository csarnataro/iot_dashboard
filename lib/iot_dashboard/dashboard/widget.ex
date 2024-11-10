defmodule IotDashboard.Dashboard.Widget do
  use Ecto.Schema
  import Ecto.Changeset

  schema "widgets" do
    field :type, :string
    field :value, :string
    field :options, :string
    field :title, :string
    field :width, :integer
    field :y, :integer
    field :x, :integer
    field :height, :integer
    field :properties, :string
    field :dashboard_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(widget, attrs) do
    widget
    |> cast(attrs, [:title, :value, :y, :x, :width, :height, :type, :properties, :options])
    |> validate_required([:title, :value, :y, :x, :width, :height, :type, :properties, :options])
  end
end
