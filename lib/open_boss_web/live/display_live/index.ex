defmodule OpenBossWeb.DisplayLive.Index do
  use OpenBossWeb, :live_view

  alias OpenBoss.Displays
  alias OpenBoss.Displays.Display

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :displays, Displays.list_display())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Display")
    |> assign(:display, Displays.get_display!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Display")
    |> assign(:display, %Display{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Display")
    |> assign(:display, nil)
  end

  @impl true
  def handle_info({OpenBossWeb.DisplayLive.FormComponent, {:saved, display}}, socket) do
    {:noreply, stream_insert(socket, :displays, display)}
  end
end
