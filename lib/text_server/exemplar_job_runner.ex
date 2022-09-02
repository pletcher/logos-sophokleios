defmodule TextServer.ExemplarJobRunner do
  use Oban.Worker, queue: :exemplars

  alias TextServer.Exemplars

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = args}) do
  	exemplar = Exemplars.get_exemplar!(id)

  	# parse exemplar, saving/updating TextNodes and TextElements

  	# set exemplar.parsed_at to Time.now()
  	:ok
  end
end
