defmodule ImgprocApiWeb.UploadController do
  use ImgprocApiWeb, :controller

  alias ImgprocApi.Uploads
  alias ImgprocApi.Uploads.Upload

	alias ImgprocApi.AmqpClient

  action_fallback ImgprocApiWeb.FallbackController

  def index(conn, _params) do
    uploads = Uploads.list_uploads()
    render(conn, "index.json", uploads: uploads)
  end

  def create(conn, %{"upload" => upload_params}) do
		IO.inspect upload_params
    with {:ok, %Upload{} = upload} <- Uploads.create_upload(upload_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.upload_path(conn, :show, upload))
      |> render("show.json", upload: upload)
    end
  end

	def upload(conn, 
		%{"file" => %{content_type: content_type, filename: _filename, path: path}, 
			"type" => type, "width" => width, "height" => height}) do
		{:ok, bytes} = File.read(path)

		{w, _} = Integer.parse(width)
		{h, _} = Integer.parse(height)

		# XXX: move these params to changeset
		headers = [{:type, type}, {:content_type, content_type}, {:width, w}, {:height, h}]

		IO.inspect headers

		response = AmqpClient.send(bytes, headers)

		conn
		|> put_resp_header("content-type", content_type)
		|> resp(:ok, response)
	end

  def show(conn, %{"id" => id}) do
    upload = Uploads.get_upload!(id)
    render(conn, "show.json", upload: upload)
  end

  def update(conn, %{"id" => id, "upload" => upload_params}) do
    upload = Uploads.get_upload!(id)

    with {:ok, %Upload{} = upload} <- Uploads.update_upload(upload, upload_params) do
      render(conn, "show.json", upload: upload)
    end
  end

  def delete(conn, %{"id" => id}) do
    upload = Uploads.get_upload!(id)

    with {:ok, %Upload{}} <- Uploads.delete_upload(upload) do
      send_resp(conn, :no_content, "")
    end
  end
end
