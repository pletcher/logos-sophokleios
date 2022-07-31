defmodule TextServer.ImagesTest do
  use TextServer.DataCase

  alias TextServer.Images

  describe "cover_images" do
    alias TextServer.Images.CoverImage

    import TextServer.ImagesFixtures

    @invalid_attrs %{attribution_name: nil, attribution_source: nil, attribution_url: nil, image_url: nil}

    test "list_cover_images/0 returns all cover_images" do
      cover_image = cover_image_fixture()
      assert Images.list_cover_images() == [cover_image]
    end

    test "get_cover_image!/1 returns the cover_image with given id" do
      cover_image = cover_image_fixture()
      assert Images.get_cover_image!(cover_image.id) == cover_image
    end

    test "create_cover_image/1 with valid data creates a cover_image" do
      valid_attrs = %{attribution_name: "some attribution_name", attribution_source: "some attribution_source", attribution_url: "some attribution_url", image_url: "some image_url"}

      assert {:ok, %CoverImage{} = cover_image} = Images.create_cover_image(valid_attrs)
      assert cover_image.attribution_name == "some attribution_name"
      assert cover_image.attribution_source == "some attribution_source"
      assert cover_image.attribution_url == "some attribution_url"
      assert cover_image.image_url == "some image_url"
    end

    test "create_cover_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Images.create_cover_image(@invalid_attrs)
    end

    test "update_cover_image/2 with valid data updates the cover_image" do
      cover_image = cover_image_fixture()
      update_attrs = %{attribution_name: "some updated attribution_name", attribution_source: "some updated attribution_source", attribution_url: "some updated attribution_url", image_url: "some updated image_url"}

      assert {:ok, %CoverImage{} = cover_image} = Images.update_cover_image(cover_image, update_attrs)
      assert cover_image.attribution_name == "some updated attribution_name"
      assert cover_image.attribution_source == "some updated attribution_source"
      assert cover_image.attribution_url == "some updated attribution_url"
      assert cover_image.image_url == "some updated image_url"
    end

    test "update_cover_image/2 with invalid data returns error changeset" do
      cover_image = cover_image_fixture()
      assert {:error, %Ecto.Changeset{}} = Images.update_cover_image(cover_image, @invalid_attrs)
      assert cover_image == Images.get_cover_image!(cover_image.id)
    end

    test "delete_cover_image/1 deletes the cover_image" do
      cover_image = cover_image_fixture()
      assert {:ok, %CoverImage{}} = Images.delete_cover_image(cover_image)
      assert_raise Ecto.NoResultsError, fn -> Images.get_cover_image!(cover_image.id) end
    end

    test "change_cover_image/1 returns a cover_image changeset" do
      cover_image = cover_image_fixture()
      assert %Ecto.Changeset{} = Images.change_cover_image(cover_image)
    end
  end
end
