defmodule OpenBossWeb.DisplayLive.FormComponent do
  use OpenBossWeb, :live_component

  alias OpenBoss.Displays

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Manage displays</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="display-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:brightness]}
          type="range"
          label="Brightness"
          min="1"
          max="100"
          step="1"
          value={@form[:brightness].value || 50}
        />
        <div class="text-sm text-gray-600 mt-1">
          Current brightness: {@form[:brightness].value || 0}%
        </div>
        <.input field={@form[:path]} type="text" label="Path" readonly disabled />
        <:actions>
          <.button phx-disable-with="Saving...">Save Display</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{display: display} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Displays.change_display(display))
     end)}
  end

  @impl true
  def handle_event("validate", %{"display" => display_params}, socket) do
    changeset = Displays.change_display(socket.assigns.display, display_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"display" => display_params}, socket) do
    save_display(socket, socket.assigns.action, display_params)
  end

  defp save_display(socket, :edit, display_params) do
    case Displays.update_display(socket.assigns.display, display_params) do
      {:ok, display} ->
        _ = Displays.apply_settings(display)
        notify_parent({:saved, display})

        {:noreply,
         socket
         |> put_flash(:info, "Display updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
