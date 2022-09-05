defmodule TextServer.ExemplarJobRunner do
  use Oban.Worker, queue: :exemplars

  alias TextServer.Exemplars

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{id: id} = _args}) do
  	exemplar = Exemplars.get_exemplar!(id)

  	# parse exemplar, saving/updating TextNodes and TextElements
  	case Exemplars.parse_exemplar(exemplar) do
  		{:ok, exemplar} ->
  			Exemplars.update_exemplar(exemplar, %{parsed_at: DateTime.utc_now()})
  			:ok

  		{:error, reason} ->
  			IO.inspect(reason)
  			:error
  	end
  end
end
