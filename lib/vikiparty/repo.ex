defmodule Vikiparty.Repo do
  use Ecto.Repo,
    otp_app: :vikiparty,
    adapter: Ecto.Adapters.Postgres
end
