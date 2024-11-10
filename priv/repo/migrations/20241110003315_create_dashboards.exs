defmodule IotDashboard.Repo.Migrations.CreateDashboards do
  use Ecto.Migration

  def change do
    create table(:dashboards) do
      add :title, :string

      timestamps(type: :utc_datetime)
    end
  end
end
