defmodule IotDashboard.DashboardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `IotDashboard.Dashboards` context.
  """

  @doc """
  Generate a dashboard.
  """
  def dashboard_fixture(attrs \\ %{}) do
    {:ok, dashboard} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> IotDashboard.Dashboards.create_dashboard()

    dashboard
  end

  @doc """
  Generate a widget.
  """
  def widget_fixture(attrs \\ %{}) do
    {:ok, widget} =
      attrs
      |> Enum.into(%{
        height: 42,
        options: "some options",
        properties: "some properties",
        title: "some title",
        type: "some type",
        value: "some value",
        width: 42,
        x: 42,
        y: 42
      })
      |> IotDashboard.Dashboards.create_widget()

    widget
  end
end
