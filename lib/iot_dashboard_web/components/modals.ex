defmodule IotDashboardWeb.Modals do
  # alias Phoenix.LiveView.JS
  # alias IotDashboardWeb.CoreComponents
  # In Phoenix apps, the line is typically: use MyAppWeb, :html
  use IotDashboardWeb, :html

  def new_widget_modal(assigns) do
    assigns =
      assigns
      |> assign(:form, to_form(%{"type" => "text", "name" => "My Widget", "property" => ""}))

    ~H"""
    <.modal show={true} id="modal" on_cancel={JS.push("hide_new_widget_modal")}>
      <h1 class="bold text-lg mt-2">Add new widget</h1>
      <.form for={@form} phx-submit="add_new_widget">
        <.input
          label="Type"
          field={@form["type"]}
          type="select"
          options={[
            {"Text", "text"},
            {"Status", "status"},
            {"Switch", "switch"},
            {"Chart", "chart"}
          ]}
        />
        <.input label="Name" field={@form["name"]} />
        <.input label="Property" field={@form["property"]} />
        <button
          type="submit"
          class="bg-blue-800 text-white px-2 py-1 rounded mt-2"
          phx-click={JS.push("hide_new_widget_modal")}
        >
          Save
        </button>
        <button
          type="button"
          class="text-gray-600 px-2 py-1 border rounded mt-2"
          phx-click={JS.push("hide_new_widget_modal")}
        >
          Cancel
        </button>
      </.form>
    </.modal>
    """
  end

  attr :widget, :any, required: true
  attr :form, :any, required: true

  def settings_modal(assigns) do
    w = assigns.widget

    heading = if Map.has_key?(w[:options], "title"), do: w[:options]["title"], else: w[:id]

    assigns =
      assigns
      |> assign(:heading, heading)

    ~H"""
    <.modal show={true} id="modal" on_cancel={JS.push("hide_settings_modal")}>
      <h1>Settings for widget <%= @heading %></h1>
      <.form for={@form} phx-submit="save_settings">
        <.input type="text" field={@form[:title]} />
        <input type="hidden" name="widget_id" value={@widget[:id]} />
        <button type="submit" class="bg-blue-800 text-white px-2 py-1 rounded mt-2">
          Save
        </button>
        <button
          type="button"
          class="text-gray-600 px-2 py-1 border rounded mt-2"
          phx-click={JS.push("hide_settings_modal")}
        >
          Cancel
        </button>
      </.form>

      <hr class="my-4" />
      <button
        type="button"
        class="bg-red-600 text-white px-2 py-1 border rounded border border-red-800"
        phx-click="delete_widget"
        phx-value-widget_id={w[:id]}
      >
        Delete widget
      </button>
      Warning: this cannot be undone
    </.modal>
    """
  end
end
