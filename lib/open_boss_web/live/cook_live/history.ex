defmodule OpenBossWeb.CookLive.History do
  use OpenBossWeb, :live_view

  alias OpenBoss.Cooks
  alias OpenBoss.Topics
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :ok = Phoenix.PubSub.subscribe(OpenBoss.PubSub, Topics.active_cook_update())
    end

    {:ok,
     socket
     |> assign(:cook, nil)
     |> assign(:cook_history, nil)}
  end

  @impl true
  def handle_event("set_timezone", %{"timezone" => timezone}, socket) do
    {:noreply, assign(socket, :timezone, timezone)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Cook History")
     |> assign(:cook, Cooks.get_cook!(id))
     |> assign(:cook_history, Cooks.get_cook_history_for_id(id))}
  end

  @impl true
  def handle_info(
        {:active_cook, %{id: update_id} = updated_cook},
        %{assigns: %{cook: cook}} = socket
      ) do
    if cook != nil and update_id == cook.id do
      {:noreply, assign(socket, :cook_history, updated_cook.cook_history)}
    else
      {:noreply, socket}
    end
  end
end
