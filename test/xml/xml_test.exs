defmodule Xml.ExemplarBodyHandlerTest do
  use ExUnit.Case

  alias Xml.ExemplarBodyHandler

  describe "ExemplarBodyHandler.set_location/3" do
    test "updates the location" do
      state = %{ref_levels: ["book", "chapter"], location: [3, 8]}
      attrs = [{"n", "4"}, {"type", "textpart"}, {"subtype", "book"}]

      assert ExemplarBodyHandler.set_location(state, "elem_name", attrs)[:location] == [4, 8]
    end

    test "updates the sub-location" do
      state = %{ref_levels: ["book", "chapter"], location: [1, 1]}
      attrs = [{"n", "4"}, {"type", "textpart"}, {"subtype", "chapter"}]

      assert ExemplarBodyHandler.set_location(state, "elem_name", attrs)[:location] == [1, 4]
    end

    test "updates the sub-sub-location" do
      state = %{ref_levels: ["book", "chapter", "paragraph"], location: [1, 1, 2]}
      attrs = [{"n", "4"}, {"type", "textpart"}, {"subtype", "paragraph"}]

      assert ExemplarBodyHandler.set_location(state, "elem_name", attrs)[:location] == [1, 1, 4]
    end

    test "zeroes out the offset if the location changes" do
      state = %{ref_levels: ["book", "chapter"], location: [3, 8], offset: 12}
      attrs = [{"n", "4"}, {"type", "textpart"}, {"subtype", "book"}]

      assert ExemplarBodyHandler.set_location(state, "elem_name", attrs)[:offset] == 0
    end

    test "does not change the offset if the location does not change" do
      state = %{ref_levels: ["book", "chapter"], location: [3, 8], offset: 12}
      attrs = [{"n", "3"}, {"type", "textpart"}, {"subtype", "book"}]

      assert ExemplarBodyHandler.set_location(state, "elem_name", attrs)[:offset] == 12
    end
  end
end
