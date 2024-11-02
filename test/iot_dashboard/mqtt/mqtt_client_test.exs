defmodule IotDashboard.Mqtt.MqttClientTest do
  use ExUnit.Case

  @hostname "test.mosquitto.org"
  @host [host: @hostname]
  @credentials [username: "rw", password: "readwrite"]
  @ssl_opts [
    cacertfile: "mosquitto.org.crt",
    server_name_indication: @hostname,
    verify: :verify_peer
  ]
  @client_cert [certfile: "client.crt", keyfile: "client.key"]
  @ipv6 [tcp_opts: [:inet6]]

  @opts_1883 @host ++ [port: 1883]
  @opts_1884 @host ++ @credentials ++ [port: 1884]
  @opts_8883 @host ++ [ssl: true, ssl_opts: @ssl_opts, port: 8883]
  @opts_8884 @host ++ [ssl: true, ssl_opts: @ssl_opts ++ @client_cert, port: 8884]
  @opts_8885 @host ++ @credentials ++ [ssl: true, ssl_opts: @ssl_opts, port: 8885]

  def connect(opts) do
    {:ok, pid} = ExMQTT.start_link(opts)
  end

  test "Connect on 1883" do
    assert {:ok, _} = connect(@opts_1883)
  end

  test "subscribe" do
    ExMQTT.subscribe("test/#", 1)
  end
end
