defmodule ImgprocApi.Repo do
  use Ecto.Repo,
    otp_app: :imgproc_api,
    adapter: Ecto.Adapters.Postgres
end
