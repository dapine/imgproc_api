defmodule ImgprocApi.UploadsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ImgprocApi.Uploads` context.
  """

  @doc """
  Generate a upload.
  """
  def upload_fixture(attrs \\ %{}) do
    {:ok, upload} =
      attrs
      |> Enum.into(%{
        file: "some file"
      })
      |> ImgprocApi.Uploads.create_upload()

    upload
  end
end
