defmodule IotDashboard.Dashboards.Dashboard do
  alias IotDashboard.Dashboards.Widget
  use Ecto.Schema
  import Ecto.Changeset

  schema "dashboards" do
    field(:title, :string)
    has_many(:widgets, Widget)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dashboard, attrs) do
    dashboard
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
