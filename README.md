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

## Front-end environment and development

We're leveraging Phoenix LiveView as much as possible for the front-end, but
occasionally we need modern niceties for CSS and JS. If you need to install a
dependency:

1. Think very carefully. Do we really need this dependency? What happens if it
   breaks?
2. Run `npm i -D <dependency>` from within the `assets/` directory.

## Commentaries

Comments get as specific as possible (e.g., up to a specific lemma); but if that
fails, specificity falls back up the citation chain (e.g., on the specific
section in Pausanias).

## TODO: Blog posts

Allow writing blog posts on commentaries in progress

## TODO

- Global find-and-replace
- Exemplar diffing (where in the pipeline?)
- Need to support uploading multiple docxs
- Show that so-and-so modified a text (important scholarly principle)
- Different approaches for translations, editions, and commentaries
  - Accommodate all three together, but don't enforce it
  - Translation could be secondary to edition and commentary
  - If the commentary is keyed to the original text (edition), translation is secondary
  - If the commentary is keyed to the translation, the edition is secondary
- Let the reader find the alignment between edition and translation
- Let the commenter point to a reference text
- Prioritize commentaries/comments --- just bring up comments
- Aim for most people to create translations and commentaries from scratch on the platform
- Use Perseus commentaries
  - Pre-ingest things to show what people can do on the platform

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
