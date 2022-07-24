defmodule TextServer.Accounts.UserNotifier do
  use Phoenix.Swoosh,
    view: TextServerWeb.UserNotifierView,
    layout: {TextServerWeb.LayoutView, :email}

  alias TextServer.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Open Commentaries", "contact@oc.newalexandria.info"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  defp unsubscribe_url(email) do
    "https://oc.newalexandria.info/unsubscribe/#{email}"
  end

  @doc """
  Deliver confirmation email with text fallback
  """
  def deliver_confirmation_email(user, url) do
    email =
      new()
      |> to(user.email)
      |> from({"Open Commentaries", "contact@oc.newalexandria.info"})
      |> subject("Please confirm your Open Commentaries email address")
      |> render_body("user_confirmation.html", %{
        unsubscribe_url: unsubscribe_url(user.email),
        url: url
      })
      |> text_body(confirmation_instructions_text(user.email, url))

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def confirmation_instructions_text(email, url) do
    """

    ==============================

    Hi #{email},

    Please confirm your Open Commentaries account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this email.

    ==============================
    """
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Open Commentaries reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your Open Commentaries password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this email.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Open Commentaries update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your Open Commentaries email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this email.

    ==============================
    """)
  end
end
