defmodule TextServer.RefsDeclsTest do
  use TextServer.DataCase

  alias TextServer.RefsDecls

  describe "refs_decls" do
    alias TextServer.RefsDecls.RefsDecl

    import TextServer.RefsDeclsFixtures

    @invalid_attrs %{description: nil, label: nil, match_pattern: nil, replacement_pattern: nil, slug: nil, structure_index: nil, urn: nil}

    test "list_refs_decls/0 returns all refs_decls" do
      refs_decl = refs_decl_fixture()
      assert RefsDecls.list_refs_decls() == [refs_decl]
    end

    test "get_refs_decl!/1 returns the refs_decl with given id" do
      refs_decl = refs_decl_fixture()
      assert RefsDecls.get_refs_decl!(refs_decl.id) == refs_decl
    end

    test "create_refs_decl/1 with valid data creates a refs_decl" do
      valid_attrs = %{description: "some description", label: "some label", match_pattern: "some match_pattern", replacement_pattern: "some replacement_pattern", slug: "some slug", structure_index: 42, urn: "some urn"}

      assert {:ok, %RefsDecl{} = refs_decl} = RefsDecls.create_refs_decl(valid_attrs)
      assert refs_decl.description == "some description"
      assert refs_decl.label == "some label"
      assert refs_decl.match_pattern == "some match_pattern"
      assert refs_decl.replacement_pattern == "some replacement_pattern"
      assert refs_decl.slug == "some slug"
      assert refs_decl.structure_index == 42
      assert refs_decl.urn == "some urn"
    end

    test "create_refs_decl/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RefsDecls.create_refs_decl(@invalid_attrs)
    end

    test "update_refs_decl/2 with valid data updates the refs_decl" do
      refs_decl = refs_decl_fixture()
      update_attrs = %{description: "some updated description", label: "some updated label", match_pattern: "some updated match_pattern", replacement_pattern: "some updated replacement_pattern", slug: "some updated slug", structure_index: 43, urn: "some updated urn"}

      assert {:ok, %RefsDecl{} = refs_decl} = RefsDecls.update_refs_decl(refs_decl, update_attrs)
      assert refs_decl.description == "some updated description"
      assert refs_decl.label == "some updated label"
      assert refs_decl.match_pattern == "some updated match_pattern"
      assert refs_decl.replacement_pattern == "some updated replacement_pattern"
      assert refs_decl.slug == "some updated slug"
      assert refs_decl.structure_index == 43
      assert refs_decl.urn == "some updated urn"
    end

    test "update_refs_decl/2 with invalid data returns error changeset" do
      refs_decl = refs_decl_fixture()
      assert {:error, %Ecto.Changeset{}} = RefsDecls.update_refs_decl(refs_decl, @invalid_attrs)
      assert refs_decl == RefsDecls.get_refs_decl!(refs_decl.id)
    end

    test "delete_refs_decl/1 deletes the refs_decl" do
      refs_decl = refs_decl_fixture()
      assert {:ok, %RefsDecl{}} = RefsDecls.delete_refs_decl(refs_decl)
      assert_raise Ecto.NoResultsError, fn -> RefsDecls.get_refs_decl!(refs_decl.id) end
    end

    test "change_refs_decl/1 returns a refs_decl changeset" do
      refs_decl = refs_decl_fixture()
      assert %Ecto.Changeset{} = RefsDecls.change_refs_decl(refs_decl)
    end
  end
end
