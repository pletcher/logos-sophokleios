## Handling TEI XML

One of the big challenges of handling these resources comes from the fact that editors prefer to work in Microsoft Word (vel sim.) while the source texts have been transcribed to TEI XML.

These XML files are a rich resource built up over decades, and --- for better or worse --- they remain the standard in the field. Open Commentaries has been struggling to build a modern translation of this format since the platform's inception. Maybe it's time to start relying more heavily on the richness of these XML resources.

To start, we should not modify the source texts. We can ditch pagination by card --- it doesn't make sense for choral odes in tragedy, for example --- but otherwise we should start trying to use the XML as a source of truth/datastore.
I don't think this means we need to use something like [eXist-db](https://github.com/eXist-db/exist) --- although maybe that's something to consider --- but rather that we extract the xpath information we need from the TEI header and query the source document directly.

This means that we'll need to store comments and edits with their canonical CTS URN references. This won't be a problem, although it might make the system a bit slower.

Postgres has built-in XML and xpath support, so we might be able to take advante of this to help ease the burden of these queries.

We can also store the documents wholesale in Postgres columns --- some of them would be very large, though.

## Migration Plan

1. Set `location` field on each `TextElement`.
1. Load XML `versions` with `xml` `refs_decl` columns.
1. Migrate comments from old OC.
1. Comments will now need to load by location, not just by `version_id` --- possibly suboptimal, but maybe we can index on location?

## Experimenting with XML

I've set up a test application for figuring out the best ways to query the underlying XML.

Just getting up and running took a few hours of trial and error, but progress is being made. I'm successfully able to query the TEI header information using Postgres's built-in `xpath` function.

But there's a catch: Postgres doesn't support default namespaces, so we need either to alias the namespace or prefix every xpath segment with `*[local-name()={name}]` --- this can be done in a macro, however, so maybe that will work.

See https://www.postgresql.org/docs/current/functions-xml.html#FUNCTIONS-XML-PROCESSING-XMLTABLE

## Some things worth considering

We'll still have to deal with the problems posed by the XML node hierarchy when it comes to commentaries and annotations. It's a win to have text and commentary/annotation separated, because they represent different textual traditions.

The way TEI XML works right now is kind of just a modern version of the medieval scribes putting text and commentary side by side --- and then later readers getting them mixed up.

Can we use XSL in a pre-processing step to separate text from commentary?

- Each annotation needs to have a URN pointing to the text that it annotates.
- When we call the text from the database, we should try just to get the `text()` of the canonical citation (from the references declaration).
- But the way that XML works, we'll also get the `text()` of every citation that occurs as a child node of the parent (reference) element.
  - There are ostensibly ways around this, but they seem to require knowing a lot more about the hierarchy than we do.


## Example queries

### Get lines from Homer

- All lines in Book 24

```elixir
from(x in fragment("select xpath('/tei:TEI/tei:text/tei:body/tei:div/tei:div[@n=?]/tei:l', xml_document, ARRAY[ARRAY['tei', 'http://www.tei-c.org/ns/1.0']])::text[] as p from xml_versions", 24), select: x.p) |> XmlPlayground.Repo.one()
```

### Get all line numbers in Book 24

```elixir
from(x in fragment("select xpath('/tei:TEI/tei:text/tei:body/tei:div/tei:div[@n=?]/tei:l/@n', xml_document, ARRAY[ARRAY['tei', 'http://www.tei-c.org/ns/1.0']])::text[] as p from xml_versions", 24), select: x.p) |> XmlPlayground.Repo.one()
```

### List of books numbers in Homer

```elixir
from(x in fragment("select xpath('/tei:TEI/tei:text/tei:body/tei:div/tei:div/@n', xml_document, ARRAY[ARRAY['tei', 'http://www.tei-c.org/ns/1.0']])::text[] as p from xml_versions"), select: x.p) |> XmlPlayground.Repo.one()
```

```elixir
def set_version_refs_decl_replacement_patterns(%Version{} = version) do
  Version
  |> where([v], v.id == ^version.id)
  |> select(
    fragment("""
    xpath('/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:refsDecl/tei:cRefPattern/@replacementPattern',
      xml_document,
      ARRAY[ARRAY['tei', 'http://www.tei-c.org/ns/1.0']]
    )::text[]
    """)
  )
  |> Repo.one()
end

def set_version_refs_decl_ref_states(%Version{} = version) do
  Version
  |> where([v], v.id == ^version.id)
  |> select(
    fragment("""
    SELECT xpath('/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:refsDecl/tei:refState/@unit',
      xml_document,
      ARRAY[ARRAY['tei', 'http://www.tei-c.org/ns/1.0']]
    )::text[]
    """)
  )
  |> Repo.one()
end
```
