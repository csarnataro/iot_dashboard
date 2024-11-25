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

  describe "dashboards" do
    alias IotDashboard.Dashboards.Dashboard

    import IotDashboard.DashboardsFixtures

    @invalid_attrs %{title: nil}

    test "list_dashboards/0 returns all dashboards" do
      dashboard = dashboard_fixture()
      assert Dashboards.list_dashboards() == [dashboard]
    end

    test "get_dashboard!/1 returns the dashboard with given id" do
      dashboard = dashboard_fixture()
      assert Dashboards.get_dashboard!(dashboard.id) == dashboard
    end

    test "create_dashboard/1 with valid data creates a dashboard" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Dashboard{} = dashboard} = Dashboards.create_dashboard(valid_attrs)
      assert dashboard.title == "some title"
    end

    test "create_dashboard/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboards.create_dashboard(@invalid_attrs)
    end

    test "update_dashboard/2 with valid data updates the dashboard" do
      dashboard = dashboard_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Dashboard{} = dashboard} = Dashboards.update_dashboard(dashboard, update_attrs)
      assert dashboard.title == "some updated title"
    end

    test "update_dashboard/2 with invalid data returns error changeset" do
      dashboard = dashboard_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboards.update_dashboard(dashboard, @invalid_attrs)
      assert dashboard == Dashboards.get_dashboard!(dashboard.id)
    end

    test "delete_dashboard/1 deletes the dashboard" do
      dashboard = dashboard_fixture()
      assert {:ok, %Dashboard{}} = Dashboards.delete_dashboard(dashboard)
      assert_raise Ecto.NoResultsError, fn -> Dashboards.get_dashboard!(dashboard.id) end
    end

    test "change_dashboard/1 returns a dashboard changeset" do
      dashboard = dashboard_fixture()
      assert %Ecto.Changeset{} = Dashboards.change_dashboard(dashboard)
    end
  end

  describe "widgets" do
    alias IotDashboard.Dashboards.Widget

    import IotDashboard.DashboardsFixtures

    @invalid_attrs %{type: nil, value: nil, options: nil, title: nil, width: nil, y: nil, x: nil, height: nil, properties: nil}

    test "list_widgets/0 returns all widgets" do
      widget = widget_fixture()
      assert Dashboards.list_widgets() == [widget]
    end

    test "get_widget!/1 returns the widget with given id" do
      widget = widget_fixture()
      assert Dashboards.get_widget!(widget.id) == widget
    end

    test "create_widget/1 with valid data creates a widget" do
      valid_attrs = %{type: "some type", value: "some value", options: "some options", title: "some title", width: 42, y: 42, x: 42, height: 42, properties: "some properties"}

      assert {:ok, %Widget{} = widget} = Dashboards.create_widget(valid_attrs)
      assert widget.type == "some type"
      assert widget.value == "some value"
      assert widget.options == "some options"
      assert widget.title == "some title"
      assert widget.width == 42
      assert widget.y == 42
      assert widget.x == 42
      assert widget.height == 42
      assert widget.properties == "some properties"
    end

    test "create_widget/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboards.create_widget(@invalid_attrs)
    end

    test "update_widget/2 with valid data updates the widget" do
      widget = widget_fixture()
      update_attrs = %{type: "some updated type", value: "some updated value", options: "some updated options", title: "some updated title", width: 43, y: 43, x: 43, height: 43, properties: "some updated properties"}

      assert {:ok, %Widget{} = widget} = Dashboards.update_widget(widget, update_attrs)
      assert widget.type == "some updated type"
      assert widget.value == "some updated value"
      assert widget.options == "some updated options"
      assert widget.title == "some updated title"
      assert widget.width == 43
      assert widget.y == 43
      assert widget.x == 43
      assert widget.height == 43
      assert widget.properties == "some updated properties"
    end

    test "update_widget/2 with invalid data returns error changeset" do
      widget = widget_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboards.update_widget(widget, @invalid_attrs)
      assert widget == Dashboards.get_widget!(widget.id)
    end

    test "delete_widget/1 deletes the widget" do
      widget = widget_fixture()
      assert {:ok, %Widget{}} = Dashboards.delete_widget(widget)
      assert_raise Ecto.NoResultsError, fn -> Dashboards.get_widget!(widget.id) end
    end

    test "change_widget/1 returns a widget changeset" do
      widget = widget_fixture()
      assert %Ecto.Changeset{} = Dashboards.change_widget(widget)
    end
  end
end
