
## Troubleshooting:

In case you have issues installing `exmqtt`, due to `emqtt` and other outdated versions, 
try to explicitly add `emqtt` as a dependency with the `override` flat set to `true`.
In addition to this, to overcome other possible subsequent issues related to `quicer` library,
add the `BUILD_WITHOUT_QUIC` flag so that the build process will not compile `quicer` and `snabbkaffe`,
which apparently are not updated in the latest version of `exmqtt`.

```elixir
      {:exmqtt, github: "ryanwinchester/exmqtt", branch: "master"},
      {:emqtt,
       github: "emqx/emqtt",
       tag: "1.13.2",
       override: true,
       system_env: [{"BUILD_WITHOUT_QUIC", "1"}]}
```


