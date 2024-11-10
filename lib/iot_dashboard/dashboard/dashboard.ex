defmodule IotDashboard.Dashboard.Dashboard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dashboards" do
    field(:title, :string)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dashboard, attrs) do
    dashboard
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
