defmodule IotDashboard.Mqtt.DisconnectHandler do
  @behaviour ExMQTT.DisconnectHandler

  @impl true

  # Catch-all
  def handle_disconnect(reason, term) do
    IO.puts("******** BEGIN: message_handler:19 ********")
    IO.inspect(reason)
    IO.inspect(term)
    IO.puts("********   END: message_handler:19 ********")
    :ok
  end
end
