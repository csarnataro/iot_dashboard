defmodule IotDashboard.Mqtt.PublishHandler do
  alias IotDashboard.Mqtt.Client
  alias Phoenix.PubSub
  # @moduledoc """
  # Publish Handler behaviour for the MQTT client.
  # Note that a publish handler is invoked when the broker publish a message on the topic,
  # not when the app publish a message
  # """
  @behaviour ExMQTT.PublishHandler

  def handle_publish(message, term) do
    message =
      case Jason.decode(message[:payload] |> String.replace("\'", "\"")) do
        {:ok, payload} ->
          %{"id" => "1", "value" => "#{payload}"}

        _ ->
          %{"value" => "N/A"}
      end

    PubSub.broadcast(
      IotDashboard.PubSub,
      Client.mqtt_updates_event(),
      {:new_mqtt_message, message}
    )
  end
end
