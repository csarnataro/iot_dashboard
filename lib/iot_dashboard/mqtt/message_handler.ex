defmodule IotDashboard.Mqtt.MessageHandler do
  @behaviour ExMQTT.MessageHandler

  @impl true

  # Catch-all
  def handle_message(topic, message, _extra) do
    IO.puts("******** BEGIN: message_handler:19 ********")
    IO.inspect(topic)
    IO.inspect(message)
    IO.puts("********   END: message_handler:19 ********")
  end
end
