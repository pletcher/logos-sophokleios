defmodule Xml.Docx.ChsDocumentHandlerTest do
  use ExUnit.Case

  alias Xml.Docx.ChsDocumentHandler

  describe "Saxy.parse_string(s, ChsDocumentHandler, state)" do
    @document """
    <w:p w14:paraId="2DB3CC5B" w14:textId="1CA5040E" w:rsidR="002E74D5" w:rsidRDefault="002E74D5">
      <w:r>
        <w:t xml:space="preserve">{1.1.2} </w:t>
      </w:r>
      <w:commentRangeStart w:id="0"/>
      <w:r>
        <w:t>It includes a comment that refers to this entire line.</w:t>
      </w:r>
      <w:commentRangeEnd w:id="0"/>
      <w:r>
        <w:rPr>
          <w:rStyle w:val="CommentReference"/>
        </w:rPr>
        <w:commentReference w:id="0"/>
      </w:r>
    </w:p>
    """
    test "handles OpenOffice XML sufficiently well" do
      {:ok, result} =
        Saxy.parse_string(
          @document,
          ChsDocumentHandler,
          %{
            text_elements: [],
            text_nodes: []
          }
        )

      assert Enum.count(result[:text_nodes]) == 1

      text_node = List.first(result[:text_nodes])

      assert text_node[:location] == [1, 1, 2]
      assert text_node[:text] == "It includes a comment that refers to this entire line."

      text_els = result[:text_elements]
      comment_start = Enum.find(text_els, &(&1[:start] == "w:commentRangeStart"))
      comment_end = Enum.find(text_els, &(&1[:end] == "w:commentRangeEnd"))

      # the comment should span the whole TextNode text
      assert comment_start[:offset] == 0
      assert comment_end[:offset] == 54
    end
  end
end
