defmodule ImgprocApi.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :file, :binary

      timestamps()
    end
  end
end
