defmodule IotDashboard.Utils.Base62Test do
  alias IotDashboard.Utils.Base62
  use ExUnit.Case

  test "Encode string" do
    assert "ciao" = Base62.encode(Base62.decode("ciao")) |> to_string()
  end

  @tag :skip
  test "Decode string" do
    assert "random_topic" = Base62.decode("abc")
  end

  @tag :skip
  test "Decode encoded string" do
    assert "random_topic" = Base62.decode(Base62.encode("random_topic"))
  end

  @tag :skip
  test "Encode decoded string" do
    assert "random_topic" = Base62.encode(Base62.decode("random_topic"))
  end
end
