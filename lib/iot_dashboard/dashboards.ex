defmodule IotDashboard.Dashboards do
  @moduledoc """
  The Dashboards context.
  """

  import Ecto.Query, warn: false
  alias IotDashboard.Dashboards.WidgetOption
  alias IotDashboard.Dashboards.WidgetRegistry
  alias IotDashboard.Repo

  alias IotDashboard.Dashboards.Dashboard

  @doc """
  Returns the list of dashboards.

  ## Examples

      iex> list_dashboards()
      [%Dashboard{}, ...]

  """
  def list_dashboards do
    Repo.all(Dashboard)
  end

  @doc """
  Gets a single dashboard.

  Raises `Ecto.NoResultsError` if the Dashboard does not exist.

  ## Examples

      iex> get_dashboard!(123)
      %Dashboard{}

      iex> get_dashboard!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dashboard!(id), do: Repo.get!(Dashboard, id) |> Repo.preload(widgets: [:options])

  def get_dashboard(id) do
    case Repo.get(Dashboard, id) |> Repo.preload(widgets: [:options]) do
      nil -> %{name: "Untitled", widgets: []}
      record -> record
    end
  end

  @doc """
  Creates a dashboard.

  ## Examples

      iex> create_dashboard(%{field: value})
      {:ok, %Dashboard{}}

      iex> create_dashboard(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dashboard(attrs \\ %{}) do
    %Dashboard{}
    |> Dashboard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dashboard.

  ## Examples

      iex> update_dashboard(dashboard, %{field: new_value})
      {:ok, %Dashboard{}}

      iex> update_dashboard(dashboard, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dashboard(%Dashboard{} = dashboard, attrs) do
    dashboard
    |> Dashboard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dashboard.

  ## Examples

      iex> delete_dashboard(dashboard)
      {:ok, %Dashboard{}}

      iex> delete_dashboard(dashboard)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dashboard(%Dashboard{} = dashboard) do
    Repo.delete(dashboard)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dashboard changes.

  ## Examples

      iex> change_dashboard(dashboard)
      %Ecto.Changeset{data: %Dashboard{}}

  """
  def change_dashboard(%Dashboard{} = dashboard, attrs \\ %{}) do
    Dashboard.changeset(dashboard, attrs)
  end

  alias IotDashboard.Dashboards.Widget

  @doc """
  Returns the list of widgets.

  ## Examples

      iex> list_widgets()
      [%Widget{}, ...]

  """
  def list_widgets do
    Repo.all(Widget) |> Repo.preload(:options)
  end

  @doc """
  Gets a single widget.

  Raises `Ecto.NoResultsError` if the Widget does not exist.

  ## Examples

      iex> get_widget!(123)
      %Widget{}

      iex> get_widget!(456)
      ** (Ecto.NoResultsError)

  """
  def get_widget!(id) do
    Repo.get!(Widget, id)
    |> Repo.preload(:options)
    |> IO.inspect()
  end

  @doc """
  Creates a widget.

  ## Examples

      iex> create_widget(%{field: value})
      {:ok, %Widget{}}

      iex> create_widget(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_widget(attrs \\ %{}) do
    %Widget{}
    |> Widget.changeset(attrs)
    |> Repo.insert()
  end

  def create_widget_with_defaults(%{
        "dashboard_id" => dashboard_id,
        "type" => type,
        "property" => property,
        "name" => name
      }) do
    widget_defaults =
      WidgetRegistry.catalog()
      |> Map.fetch!(String.to_existing_atom(type))
      |> Map.fetch!(:defaults)

    name = if name, do: name, else: widget_defaults[:name]

    attrs_with_default = %{
      :x => 0,
      :y => 0,
      :width => widget_defaults[:width],
      :height => widget_defaults[:height],
      :type => type,
      :properties => property,
      :dashboard_id => dashboard_id,
      :options => [%{:name => "name", :value => name}]
    }

    create_widget(attrs_with_default)
  end

  @doc """
  Updates a widget by widget_id

  ## Examples

      iex> update_widget("1", %{field: new_value})
      {:ok, %Widget{}}

      iex> update_widget(1, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_widget_properties(widget_id, attrs) when is_binary(widget_id) do
    %{properties: properties} = attrs

    from(w in Widget, where: w.id == ^widget_id)
    |> Repo.update_all(set: [properties: properties])
  end

  def update_widget(widget_id, attrs) when is_binary(widget_id) do
    widget = get_widget!(widget_id)

    update_widget(widget, attrs)
    # from(w in Widget, where: w.id == ^widget_id)
    # |> Repo.update_all(set: attrs)
  end

  @doc """
  Updates a widget.

  ## Examples

      iex> update_widget(widget, %{field: new_value})
      {:ok, %Widget{}}

      iex> update_widget(widget, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_widget(%Widget{} = widget, attrs) do
    widget
    |> Widget.changeset(attrs)
    |> Repo.update()
  end

  def delete_widget(widget_id) when is_binary(widget_id) do
    from(x in Widget, where: x.id == ^widget_id) |> Repo.delete_all()
  end

  @doc """
  Deletes a widget.

  ## Examples

      iex> delete_widget(widget)
      {:ok, %Widget{}}

      iex> delete_widget(widget)
      {:error, %Ecto.Changeset{}}

  """
  def delete_widget(%Widget{} = widget) do
    Repo.delete(widget)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking widget changes.

  ## Examples

      iex> change_widget(widget)
      %Ecto.Changeset{data: %Widget{}}

  """
  def change_widget(%Widget{} = widget, attrs \\ %{}) do
    Widget.changeset(widget, attrs)
  end

  def update_last_value(dashboard_id, property_name, value) do
    IO.puts("******** BEGIN: Dashboards:272 ********")
    dbg(property_name)
    dbg(value)
    IO.puts("********   END: Dashboards:272 ********")

    from(w in Widget, where: w.dashboard_id == ^dashboard_id and w.properties == ^property_name)
    |> Repo.update_all(set: [value: value])

    # # def update_widget(%Widget{} = widget, attrs) do
    # #   widget
    # #   |> Widget.changeset(attrs)
    # #   |> Repo.update()
    # # end
    # non_updated_widgets =
    #   dashboard.widgets
    #   |> Enum.filter(fn w -> !has_property?(w, property_name) end)

    # updated_widgets =
    #   dashboard.widgets
    #   |> Enum.filter(fn w -> has_property?(w, property_name) end)
    #   |> Enum.map(fn w -> Map.put(w, :value, value) end)

    # all_widgets = updated_widgets ++ non_updated_widgets

    # new_dashboard = %{dashboard | widgets: all_widgets}
    # {:reply, new_dashboard, new_dashboard}
  end
end
