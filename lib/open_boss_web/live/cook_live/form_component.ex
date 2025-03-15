defmodule OpenBossWeb.CookLive.FormComponent do
  use OpenBossWeb, :live_component

  alias OpenBoss.Cooks
  alias OpenBoss.Devices

  require Logger

  @impl true
  def update(%{cook: cook} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:devices, Devices.list())
     |> assign_new(:form, fn ->
       to_form(Cooks.change_cook(cook))
     end)}
  end

  @impl true
  def handle_event("validate", %{"cook" => cook_params}, socket) do
    cook_params = adjust_cook_for_save(cook_params, socket.assigns.timezone)
    changeset = Cooks.change_cook(socket.assigns.cook, cook_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"cook" => cook_params}, socket) do
    save_cook(socket, socket.assigns.action, cook_params)
  end

  defp save_cook(socket, :edit, cook_params) do
    cook_params = adjust_cook_for_save(cook_params, socket.assigns.timezone)

    case Cooks.update_cook(socket.assigns.cook, cook_params) do
      {:ok, cook} ->
        notify_parent({:saved, cook})

        {:noreply,
         socket
         |> put_flash(:info, "Cook updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_cook(socket, :new, cook_params) do
    cook_params = adjust_cook_for_save(cook_params, socket.assigns.timezone)

    case Cooks.create_cook(cook_params) do
      {:ok, cook} ->
        notify_parent({:saved, cook})

        {:noreply,
         socket
         |> put_flash(:info, "Cook created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  @spec adjust_cook_for_save(map(), String.t()) :: map()
  defp adjust_cook_for_save(cook_params, timezone) do
    for field <- ["start_time", "stop_time"], into: cook_params do
      {field, OpenBoss.Utils.browser_time_to_dt(cook_params[field], timezone)}
    end
  end
end
