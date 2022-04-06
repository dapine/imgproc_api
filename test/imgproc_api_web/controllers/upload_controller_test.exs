defmodule ImgprocApiWeb.UploadControllerTest do
  use ImgprocApiWeb.ConnCase

  import ImgprocApi.UploadsFixtures

  alias ImgprocApi.Uploads.Upload

  @create_attrs %{
    file: "some file"
  }
  @update_attrs %{
    file: "some updated file"
  }
  @invalid_attrs %{file: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all uploads", %{conn: conn} do
      conn = get(conn, Routes.upload_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create upload" do
    test "renders upload when data is valid", %{conn: conn} do
      conn = post(conn, Routes.upload_path(conn, :create), upload: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.upload_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "file" => "some file"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.upload_path(conn, :create), upload: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update upload" do
    setup [:create_upload]

    test "renders upload when data is valid", %{conn: conn, upload: %Upload{id: id} = upload} do
      conn = put(conn, Routes.upload_path(conn, :update, upload), upload: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.upload_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "file" => "some updated file"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, upload: upload} do
      conn = put(conn, Routes.upload_path(conn, :update, upload), upload: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete upload" do
    setup [:create_upload]

    test "deletes chosen upload", %{conn: conn, upload: upload} do
      conn = delete(conn, Routes.upload_path(conn, :delete, upload))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.upload_path(conn, :show, upload))
      end
    end
  end

  defp create_upload(_) do
    upload = upload_fixture()
    %{upload: upload}
  end
end
