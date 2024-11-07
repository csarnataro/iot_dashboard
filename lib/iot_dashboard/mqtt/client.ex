defmodule IotDashboard.Mqtt.Client do
  alias IotDashboard.Mqtt.DisconnectHandler
  alias IotDashboard.Mqtt.PublishHandler

  @topic "test/csarnataro/#"
  @hostname "broker.hivemq.com"
  @host [host: @hostname]
  @port 1883
  @base_opts @host ++ [port: @port] ++ [client_id: "test_client_id"]
  @qos 0
  def mqtt_updates_event, do: "mqtt_updates"

  def start do
    opts =
      @base_opts ++
        [publish_handler: {PublishHandler, []}] ++
        [disconnect_handler: {DisconnectHandler, []}]

    case ExMQTT.start_link(opts) do
      {:ok, _} ->
        ExMQTT.subscribe(@topic, @qos)

      {:error, {:already_started, _}} ->
        nil
    end
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(IotDashboard.PubSub, topic)
  end
end
