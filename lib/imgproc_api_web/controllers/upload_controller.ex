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

	@type upload_params :: %{
		file: Plug.Upload.t,
		type: String.t,
		width: integer,
		height: integer,
		angle: integer
	}

	@spec upload(Plug.Conn.t, upload_params) :: Plug.Conn.t
	def upload(conn, params) do
		%{"file" => %{content_type: content_type, filename: _filename, path: path}} = params
		%{"type" => type} = params

		{:ok, bytes} = File.read(path)
		headers = resolve_headers(params)
		{exchange, key} = resolve_queue(type)

		response = AmqpClient.send(exchange, key, bytes, headers)

		conn
		|> put_resp_header("content-type", content_type)
		|> resp(:ok, response)
	end

	defp resolve_queue(type) do
		case type do
			"resize" -> {"image_processing", "resize"}
			"rotate" -> {"image_processing", "rotate"}
			"convert" -> {"image_processing", "convert"}
			"crop" -> {"image_processing", "crop"}
			"enlarge" -> {"image_processing", "enlarge"}
			"extract" -> {"image_processing", "extract"}
			"flip" -> {"image_processing", "flip"}
		end
	end

	defp resolve_headers(params) do
		%{"type" => type} = params
		%{"file" => %{content_type: content_type, filename: _filename, path: _path}} = params
		case type do
			"resize" ->
				%{"width" => width, "height" => height} = params

				{w, _} = Integer.parse(width)
				{h, _} = Integer.parse(height)

				[{:content_type, content_type}, {:width, w}, {:height, h}]
			"rotate" ->
				%{"angle" => angle} = params

				{a, _} = Integer.parse(angle)

				[{:content_type, content_type}, {:angle, a}]
			"convert" ->
				%{"target_image_type" => target} = params

				[{:content_type, content_type}, {:target_image_type, target}]
			"crop" ->
				%{"width" => width, "height" => height, "gravity" => gravity} = params

				{w, _} = Integer.parse(width)
				{h, _} = Integer.parse(height)

				[{:content_type, content_type}, {:width, w}, {:height, h}, {:gravity, gravity}]
			"enlarge" ->
				%{"width" => width, "height" => height} = params

				{w, _} = Integer.parse(width)
				{h, _} = Integer.parse(height)

				[{:content_type, content_type}, {:width, w}, {:height, h}]
			"extract" ->
				%{"width" => width, "height" => height, "x" => x, "y" => y} = params

				{w, _} = Integer.parse(width)
				{h, _} = Integer.parse(height)
				{xx, _} = Integer.parse(x)
				{yy, _} = Integer.parse(y)

				[{:content_type, content_type}, {:width, w}, {:height, h}, {:x, xx}, {:y, yy}]
			"flip" ->
				%{"axis" => axis} = params
				[{:content_type, content_type}, {:axis, axis}]
		end
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
