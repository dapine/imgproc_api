defmodule ImgprocApi.Uploads.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uploads" do
    field :file, :binary

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:file])
    |> validate_required([:file])
  end
end
