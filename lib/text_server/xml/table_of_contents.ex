defmodule TextServer.Xml.TableOfContents do
  @moduledoc """
  This module helps to generate tables of contents based on a list
  of lists of possible citation levels, starting from the deepest
  level of citation. (So if a reference goes Book.Chapter.Line, the first
  array is a list of lines --- it normally repeats.) E.g., for Pausanias,
  that list looks something like:any()

  ```elixir
  [
    # sections
    [1, 2, 3, 4, 5, 1, 2, 3, ...],
    # chapters
    [1, 2, 3, 4, 5, ...],
    # books
    [1, 2, 3, 4, 5, ...]
  ]
  ```

  Where every time the number in the `sections` array returns to
  its base state (1), it represents a change of chapter; and likewise,
  every time the `chapters` array returns to its base state (1), it represents
  a change of book.

  It is assumed that the last array does not repeat but simply counts up.

  For a dialogue of Plato, the arrays would look like this:

  ```elixir
  [
    # stephanus section
    [a, b, c, d, e, a, b, c, d, e, ...],
    # stephanus page
    [50, 51, 52, ...]
  ]
  ```

  or, for _Republic_ or _Laws_:

  ```elixir
  [
    # stephanus section
    [a, b, c, d, e, a, b, c, d, e],
    # stephanus page
    [327, 328, 329, ...],
    # book
    [1, 2, 3, ...]
  ]
  ```

  From this input, collect_citations/1 returns a complete list of canonical citation tuples,
  e.g., for a three-level hierarchy:

  ```elixir
  [
    [1, 1, 1],
    [1, 1, 2],
    [1, 1, 3],
    [1, 2, 1],
    [1, 2, 2],
    [2, 1, 1],
    ...
  ]
  ```

  Right now, we only support hierarchies up to three levels deep. Support could be
  added for additional depths as needed. (The algorithm should probably
  be generalized to handle inputs of arbitrary levels.)

  TODO: Can xpath 1.0 accomplish this more easily?
  """
  def collect_citations(passage_refs) when length(passage_refs) == 1 do
    passage_refs |> List.first() |> Enum.map(&String.to_integer/1)
  end

  def collect_citations(passage_refs, grouped \\ [])

  def collect_citations([], grouped), do: grouped

  def collect_citations(passage_refs, grouped) when length(passage_refs) == 3 do
    [sections, chapters, books] = passage_refs

    current_sections = get_current_level(sections)
    [current_chapter | rest_chapters] = chapters
    [current_book | rest_books] = books

    citations =
      for section <- current_sections do
        {current_book, current_chapter, section}
      end

    rest_sections = sections -- current_sections

    if Enum.count(rest_sections) == 0 do
      [citations | grouped] |> List.flatten()
    else
      next_books =
        if is_greater(current_chapter, List.first(rest_chapters)) do
          rest_books
        else
          books
        end

      collect_citations([rest_sections, rest_chapters, next_books], [citations | grouped])
    end
  end

  def collect_citations(passage_refs, grouped) when length(passage_refs) == 2 do
    [lines, books] = passage_refs

    current_lines = get_current_level(lines)
    [current_book | rest_books] = books

    citations =
      for line <- lines do
        {current_book, line}
      end

    rest_lines = lines -- current_lines

    if Enum.count(rest_lines) == 0 do
      [citations | grouped] |> List.flatten()
    else
      collect_citations([rest_lines, rest_books], [citations | grouped])
    end
  end

  defp get_current_level(sections) do
    sections
    |> Enum.reduce_while([], fn section, acc ->
      if is_greater(section, List.first(acc)) do
        {:cont, [section | acc]}
      else
        {:halt, acc}
      end
    end)
  end

  defp is_greater(x, y) do
    to_comparable(x) > to_comparable(y)
  end

  # These cover Plato and Aristotle --- what else do we need?
  @letter_citations ["a", "b", "c", "d", "e"]

  defp to_comparable(x) when is_nil(x), do: 0

  defp to_comparable(x) when is_binary(x) do
    if Enum.member?(@letter_citations, x) do
      x
    else
      String.to_integer(x, 10)
    end
  end

  defp to_comparable(x) when is_integer(x), do: x
end
