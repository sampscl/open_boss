defmodule OpenBossWeb.DevicesLive.FormComponent do
  use OpenBossWeb, :live_component

  alias OpenBoss.Devices.Device
  alias OpenBoss.Devices.Manager
  alias OpenBoss.Repo
  alias OpenBoss.Utils

  @impl true
  def update(%{device: device} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Ecto.Changeset.change(device))
     end)}
  end

  @impl true
  def handle_event("validate", %{"device" => device_params}, socket) do
    device_params = adjust_device_for_save(device_params)
    changeset = Device.changeset(socket.assigns.device, device_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"device" => device_params}, socket) do
    save_device(socket, socket.assigns.action, device_params)
  end

  defp save_device(socket, :edit, device_params) do
    {_, updated_params} =
      Map.get_and_update(device_params, "set_temp", fn
        nil ->
          {nil, nil}

        farenheit_str ->
          {farenheit, _} = Float.parse(farenheit_str)
          {farenheit, OpenBoss.Utils.farenheit_to_celsius(farenheit)}
      end)

    changeset =
      Device.changeset(
        socket.assigns.device,
        updated_params
      )

    case Repo.update(changeset) do
      {:ok, device} ->
        if Ecto.Changeset.changed?(changeset, :set_temp),
          do: Manager.set_temp(device.id, updated_params["set_temp"], :celsius)

        notify_parent({:saved, device})

        {:noreply,
         socket
         |> put_flash(:info, "#{Device.get_name(device)} updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  @spec adjust_device_for_save(map()) :: map()
  defp adjust_device_for_save(device_state) do
    Map.update!(device_state, "set_temp", fn farenheit ->
      {val, _} = Float.parse(farenheit)
      Utils.farenheit_to_celsius(val)
    end)
  end
end
