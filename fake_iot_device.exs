defmodule FakeIotClient do
  import ExMQTT

  @client_id "test_iot_device"

  # @hostname "broker.hivemq.com"
  @hostname "1de5f12817c24910b3877de195ad7883.s1.eu.hivemq.cloud"
  @host [host: @hostname]
  @port 8883
  @username "csarnataro"
  @password "Ottobre2024"
  @base_opts @host ++
               [port: @port] ++
               [client_id: @client_id] ++
               [password: @password] ++
               [username: @username]

  {:ok, _conn_pid} = ExMQTT.start_link(@base_opts)
  @topic "test/csarnataro/"
  @qos 0

  def publish_temperature(temperature) do
    ExMQTT.publish(to_string(temperature), @topic <> "temperature", @qos)

    ExMQTT.publish(
      to_string(if :rand.uniform() < 0.5, do: "true", else: "false"),
      @topic <> "humidity",
      @qos
    )

    :timer.sleep(1_000)

    publish_temperature(temperature + 1)
  end
end

FakeIotClient.publish_temperature(0)
