defmodule IotDashboard.Repo do
  use Ecto.Repo,
    otp_app: :iot_dashboard,
    adapter: Ecto.Adapters.SQLite3
end
