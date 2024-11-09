defmodule IotDashboard.DashboardsTest do
  alias IotDashboard.Widget
  alias IotDashboard.Dashboards
  use ExUnit.Case

  test "has property should return false for empty widget" do
    w = %Widget{id: "1"}
    assert Dashboards.has_property?(w, "temp") == false
  end

  test "has property should return false for widget with other properties" do
    w = %Widget{id: "1", properties: ["hum", "light"]}
    assert Dashboards.has_property?(w, "temp") == false
  end

  test "has property should return false for widget with nil property" do
    w = %Widget{id: "1", properties: nil}
    assert Dashboards.has_property?(w, "temp") == false
  end

  test "has property should return true for widget with valid property" do
    w = %Widget{id: "1", properties: ["temp"]}
    assert Dashboards.has_property?(w, "temp") == true
  end
end
