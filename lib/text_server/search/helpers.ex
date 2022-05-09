# borrowed from https://elixirforum.com/t/how-to-properly-sanitize-multiple-ts-vector-fields-with-reusable-macro/34614/11

defmodule TextServer.Search.Helpers do
  defmacro tsquery(tsvector, terms, language \\ "english") do
    quote do
      fragment(
        "? @@ to_tsquery(?, ?)",
        unquote(tsvector),
        unquote(language),
        unquote(terms)
      )
    end
  end

  defmacro tsrankcd(tsvector, terms, language \\ "english") do
    quote do
      fragment(
        "ts_rank_cd(?, to_tsquery(?, ?))",
        unquote(tsvector),
        unquote(language),
        unquote(terms)
      )
    end
  end
end
