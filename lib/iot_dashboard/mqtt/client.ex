defmodule IotDashboard.Mqtt.Client do
  alias IotDashboard.Mqtt.DisconnectHandler
  alias IotDashboard.Mqtt.PublishHandler

  @topic "test/csarnataro/#"
  # @hostname "broker.hivemq.com"
  @hostname "1de5f12817c24910b3877de195ad7883.s1.eu.hivemq.cloud"
  @host [host: @hostname]
  @port 8883
  @client_id "test_client_id"
  @username "csarnataro"
  @password "Ottobre2024!"
  @base_opts @host ++
               [port: @port] ++
               [client_id: @client_id] ++
               [password: @password] ++
               [username: @username]

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

  def send_message(message, property) do
    IO.puts("******** BEGIN: client:34 ********")
    IO.puts("Sending #{message} to test/csarnataro/#{property}")
    IO.puts("********   END: client:34 ********")
    ExMQTT.publish(message, "test/csarnataro/" <> property, @qos)
  end
end
