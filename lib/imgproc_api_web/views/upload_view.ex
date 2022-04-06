defmodule ImgprocApiWeb.UploadView do
  use ImgprocApiWeb, :view
  alias ImgprocApiWeb.UploadView

  def render("index.json", %{uploads: uploads}) do
    %{data: render_many(uploads, UploadView, "upload.json")}
  end

  def render("show.json", %{upload: upload}) do
    %{data: render_one(upload, UploadView, "upload.json")}
  end

  def render("upload.json", %{upload: upload}) do
    %{
      id: upload.id,
      file: upload.file
    }
  end
end
