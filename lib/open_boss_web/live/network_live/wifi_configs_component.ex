defmodule OpenBossWeb.NetworkLive.WifiConfigsComponent do
  use OpenBossWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Manage WiFi Networks</:subtitle>
      </.header>

      <.table id="wifi-configurations" rows={@configurations}>
        <:col :let={config} label="SSID">{config.ssid}</:col>
        <:col :let={config} label="Security">{config.security}</:col>
        <:col :let={config} label="Priority">{config.priority}</:col>

        <:action :let={config}>
          <.button phx-click="edit-config" phx-target={@myself} phx-value-id={config.id}>
            Edit
          </.button>
          <.button phx-click="delete-config" phx-target={@myself} phx-value-id={config.id}>
            Delete
          </.button>
        </:action>
      </.table>

      <.button phx-click="add-config" phx-target={@myself}>
        Add Network
      </.button>
    </div>
    """
  end

  @impl true
  def handle_event("edit-config", %{"id" => _id}, socket) do
    # Implementation for editing an existing WiFi configuration
    socket
  end
end
