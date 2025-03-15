defmodule OpenBoss.NetworkTest do
  use OpenBoss.DataCase

  alias OpenBoss.Network

  test "update_adapter/2 accepts wifi changes" do
    configuration = build(:wifi_configuration)
    adapter = build(:adapter)

    assert :ok =
             Network.update_adapter(
               adapter,
               %{configuration: configuration}
             )
  end
end
