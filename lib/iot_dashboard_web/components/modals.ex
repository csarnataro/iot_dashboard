defmodule IotDashboardWeb.Modals do
  # alias Phoenix.LiveView.JS
  # alias IotDashboardWeb.CoreComponents
  # In Phoenix apps, the line is typically: use MyAppWeb, :html
  alias IotDashboard.Dashboards.WidgetRegistry
  alias IotDashboard.Dashboards.Widget
  use IotDashboardWeb, :html

  def new_widget_modal(assigns) do
    default_name =
      WidgetRegistry.catalog()
      |> Map.fetch!(assigns.selected_widget_type)
      |> Map.fetch!(:defaults)
      |> Map.fetch!(:name)

    assigns =
      assigns
      |> assign(
        :form,
        to_form(%{"type" => "text", "name" => default_name, "property" => ""})
      )

    ~H"""
    <.modal show={true} id="modal" on_cancel={JS.push("hide_new_widget_modal")}>
      <h1 class="bold text-lg mt-2">Add new widget</h1>
      <.form for={@form} phx-submit="add_new_widget">
        <input type="hidden" name="dashboard_id" value={@dashboard_id} />
        <.input
          label="Type"
          field={@form["type"]}
          type="select"
          options={WidgetRegistry.options_for_select()}
          phx-change="change_new_widget_type"
          onchange="document.getElementById('default_name').value = `My ` + this.options[this.selectedIndex].innerText"
        />
        <.input label="Name" field={@form["name"]} id="default_name" />
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
  attr :id, :string, required: true

  def settings_modal(assigns) do
    %{widget: widget} = assigns

    # IO.puts("******** BEGIN: modals:57 ********")
    # dbg(w2)
    # IO.puts("********   END: modals:57 ********")
    # widget = assigns.widget

    heading =
      widget.options
      |> Widget.option("name")

    # heading = "Hey"

    # if Map.has_key?(w.options, "title"), do: w.options["title"], else: w.id

    assigns =
      assigns
      |> assign(:heading, heading)
      |> assign(:widget_id, widget.id)

    ~H"""
    <.modal show={true} id="modal" on_cancel={JS.push("hide_settings_modal")}>
      <h1>Settings for widget <%= @heading %></h1>
      <.form id={@id} for={@form} phx-submit="save_settings">
        <input type="hidden" name="widget[id]" value={@form.data.id} />
        <.input label="Property (MQTT topic name)" type="text" field={@form[:properties]} />
        <.inputs_for :let={f_line} field={@form[:options]}>
          <.input class="mt-0" field={f_line[:value]} label={f_line.data.name |> String.capitalize()} />
        </.inputs_for>

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
      <fieldset class="border border-red-600 rounded rounded-lg p-4">
        <legend class="text-red-600 mx-2">Danger zone</legend>
        <div class="flex justify-between">
          <div class="flex flex-col flex-1 text-red-600">
            <div>Delete widget</div>
            <div class="text-xs">The widget will be permanently removed from the dashboard</div>
          </div>
          <button
            type="button"
            class="bg-red-600 text-white px-2 py-1 border rounded border border-red-800"
            phx-click="delete_widget"
            phx-value-widget_id={@widget_id}
          >
            Delete
          </button>
        </div>
      </fieldset>
    </.modal>
    """
  end
end
