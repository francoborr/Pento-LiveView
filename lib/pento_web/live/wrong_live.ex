defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  def mount(_params, session, socket) do
    {:ok,
     assign(socket,
       score: 0,
       message: "Make a guess:",
       time: DateTime.utc_now() |> to_string(),
       result: Enum.random(1..10),
       has_won: false,
       #  authentication security (we have this on the `on_mount` of the live sesion)
       session_id: session["live_socket_id"]
     )}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl font-extrabold">Your score: <%= @score %></h1>

    <h2>
      <%= @message %> It's <%= @time %>
    </h2>
    <br />
    <h2>
      <%= if not @has_won do %>
        <%= for n <- 1..10 do %>
          <.link
            class="bg-blue-500 hover:bg-blue-700
          text-white font-bold py-2 px-4 border border-blue-700 rounded m-1"
            phx-click="guess"
            phx-value-number={n}
          >
            <%= n %>
          </.link>
        <% end %>
      <% else %>
        <.link
          class="bg-blue-500 hover:bg-blue-700
        text-white font-bold py-2 px-4 border border-blue-700 rounded m-1"
          phx-click="reset"
        >
          Reset!
        </.link>
      <% end %>
    </h2>

    <br />
    <pre>
    <%= @current_user.email %>
    <%= @session_id %>
    </pre>
    """
  end

  def handle_event("guess", %{"number" => guess}, socket) do
    %{message: message, score: score, has_won: has_won} =
      handle_guess_number(guess, to_string(socket.assigns.result), socket)

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score,
        time: DateTime.utc_now() |> to_string(),
        has_won: has_won
      )
    }
  end

  def handle_event("reset", _, socket) do
    {
      :noreply,
      assign(
        socket,
        message: "Make a guess:",
        score: 0,
        result: Enum.random(1..10),
        time: DateTime.utc_now() |> to_string(),
        has_won: false
      )
    }
  end

  defp handle_guess_number(guess, result, socket) when guess == result do
    %{message: "Your won!", score: socket.assigns.score + 1, has_won: true}
  end

  defp handle_guess_number(guess, _, socket),
    do: %{
      message: "Your guess: #{guess}. Wrong. Guess again.",
      score: socket.assigns.score - 1,
      has_won: false
    }
end
