defmodule IotDashboard.Mqtt.Client do
  alias IotDashboard.Mqtt.DisconnectHandler
  alias IotDashboard.Mqtt.PublishHandler

  @topic "/test/csarnataro/#"
  @hostname "test.mosquitto.org"
  @host [host: @hostname]
  @port 1883
  @base_opts @host ++ [port: @port] ++ [client_id: "test_client_id"]

  def mqtt_updates_event, do: "mqtt_updates"

  def start do
    opts =
      @base_opts ++
        [publish_handler: {PublishHandler, []}] ++
        [disconnect_handler: {DisconnectHandler, []}]

    case ExMQTT.start_link(opts) do
      {:ok, _} ->
        ExMQTT.subscribe(@topic, 1)

      {:error, {:already_started, _}} ->
        nil
    end
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(IotDashboard.PubSub, topic)
  end
end
