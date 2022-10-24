defmodule Mix.Tasks.Exemplars.Paginate do
  import Ecto.Query

  use Mix.Task

  alias TextServer.Repo
  alias TextServer.TextNodes.TextNode

  def run(args) do
    Mix.Task.run("app.start")

    {parsed, _argv, _error} = OptionParser.parse(args, strict: [id: :integer])

    exemplar_id = Keyword.get(parsed, :id)

    paginate_pausanias(exemplar_id)

    #   # pagination is actually not as straightforward as one might think:
    #   # for something that only has one level of reference,
    #   # for example, like drama, we need to be able to create
    #   # cards manually -- we could determine scenes algorithmically,
    #   # kind of, but manual entry makes much more sense.
    #   # but for Pausanias, for now, we just need to pay attention
    #   # to the second element in the location array
  end

  defp paginate_pausanias(exemplar_id) do
    q =
      from(
        t in TextNode,
        where: t.exemplar_id == ^exemplar_id,
        order_by: [asc: t.location]
      )

    grouped_text_nodes =
      Repo.all(q)
      |> Enum.filter(fn tn -> tn.location != [0] end)
      |> Enum.group_by(fn tn ->
        [first | tail] = tn.location
        [second | _rest] = tail

        {first, second}
      end)

    keys = Map.keys(grouped_text_nodes) |> Enum.sort()

    keys
    |> Enum.with_index()
    |> Enum.each(fn {k, i} ->
      text_nodes = Map.get(grouped_text_nodes, k)
      first_node = List.first(text_nodes)
      last_node = List.last(text_nodes)

      TextServer.Exemplars.create_page(%{
        end_text_node_id: last_node.id,
        exemplar_id: exemplar_id,
        page_number: i + 1,
        start_text_node_id: first_node.id
      })
    end)
  end
end
