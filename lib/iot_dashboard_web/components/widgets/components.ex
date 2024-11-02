defmodule IotDashboardWeb.Widgets.Components do
  alias IotDashboardWeb.Widgets.Text

  defdelegate text(assigns), to: Text, as: :display
end
