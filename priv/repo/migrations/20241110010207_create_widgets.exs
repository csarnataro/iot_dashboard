defmodule IotDashboard.Repo.Migrations.CreateWidgets do
  use Ecto.Migration

  def change do
    create table(:widgets) do
      add :value, :string
      add :y, :integer
      add :x, :integer
      add :width, :integer
      add :height, :integer
      add :type, :string
      add :properties, :string
      add :options, :string
      add :dashboard_id, references(:dashboards, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:widgets, [:dashboard_id])
  end
end
