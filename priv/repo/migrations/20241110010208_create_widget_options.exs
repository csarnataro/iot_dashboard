defmodule IotDashboard.Repo.Migrations.CreateWidgetOptions do
  use Ecto.Migration

  def change do
    create table(:widget_options) do
      add :value, :string
      add :name, :string
      add :widget_id, references(:widgets, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:widget_options, [:widget_id])
  end
end
