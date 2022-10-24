defmodule Mix.Tasks.Exemplars.Paginate do
  use Mix.Task

  alias TextServer.Exemplars

  def run(args) do
    Mix.Task.run("app.start")

    {parsed, _argv, _error} = OptionParser.parse(args, strict: [id: :integer])

    exemplar_id = Keyword.get(parsed, :id)

    paginate(exemplar_id)

    #   # pagination is actually not as straightforward as one might think:
    #   # for something that only has one level of reference,
    #   # for example, like drama, we need to be able to create
    #   # cards manually -- we could determine scenes algorithmically,
    #   # kind of, but manual entry makes much more sense.
    #   # but for Pausanias, for now, we just need to pay attention
    #   # to the second element in the location array
  end

  defp paginate(exemplar_id) do
    Exemplars.paginate_exemplar(exemplar_id)
  end
end
