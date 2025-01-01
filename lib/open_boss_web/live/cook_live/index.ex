defmodule OpenBossWeb.CookLive.Index do
  use OpenBossWeb, :live_view

  alias OpenBoss.Cooks
  alias OpenBoss.Cooks.Cook

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    # start with an empty stream of cooks and populate
    # later when we have browser timezone for proper
    # rendering
    {:ok, stream(socket, :cooks, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Cook")
    |> assign(:cook, Cooks.get_cook!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Cook")
    |> assign(:cook, %Cook{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Cooks")
    |> assign(:cook, nil)
  end

  @impl true
  def handle_info({OpenBossWeb.CookLive.FormComponent, {:saved, cook}}, socket) do
    {:noreply, stream_insert(socket, :cooks, cook)}
  end

  @impl true
  def handle_event("set_timezone", %{"timezone" => timezone}, socket) do
    {:noreply,
     socket
     |> stream(:cooks, Cooks.list_cooks())
     |> assign(:timezone, timezone)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    cook = Cooks.get_cook!(id)
    {:ok, _} = Cooks.purge_cook(cook)

    {:noreply, stream_delete(socket, :cooks, cook)}
  end
end
