defmodule Mix.Tasks.Versions.Paginate do
  use Mix.Task

  alias TextServer.Versions

  def run(args) do
    Mix.Task.run("app.start")

    {parsed, _argv, _error} = OptionParser.parse(args, strict: [id: :integer])

    version_id = Keyword.get(parsed, :id)

    paginate(version_id)

    #   # pagination is actually not as straightforward as one might think:
    #   # for something that only has one level of reference,
    #   # for example, like drama, we need to be able to create
    #   # cards manually -- we could determine scenes algorithmically,
    #   # kind of, but manual entry makes much more sense.
    #   # but for Pausanias, for now, we just need to pay attention
    #   # to the second element in the location array
  end

  defp paginate(version_id) do
    Versions.paginate_version(version_id)
  end
end
