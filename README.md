# New Alexandria Foundation Text Server

## About the schema

We follow the [CTS URN spec](http://cite-architecture.github.io/ctsurn_spec/),
which can at tims be confusing.

Essentially, every `collection` (which is roughly analogous to a git repository)
contains one or more `text_group`s. It can be helpful to think of each
`text_group` as an author, but remember that "author" here designates not a
person but rather a loose grouping of works related by style, content, and
(usually) language. Sometimes the author is "anonymous" or "unknown" --- hence
`text_group` instead of "author".

Each `text_group` contains one or more `work`s. You might think of these as
texts.

A `work` can be further specified by a `version` URN component that points to
either an `edition` (in the traditional sense of the word) or a `translation`.

Each `version` can also have a specific imprint, known as an `exemplar`.

So in rough database speak:

- An `exemplar` belongs to a `version`
- A `version` has a type indication of either `edition` or `translation`
- A `version` belongs to a `work`
- A `work` belongs to a `text_group`
- A `text_group` belongs to a `collection`

In reverse:

- A `collection` has many `text_group`s
- A `text_group` has many `work`s
- A `work` _optionally_ has many `version`s, each of which is typed as `edition` or
  `translation`
- A `version` _optionally_ has many `exemplar`s

## Running in development

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
