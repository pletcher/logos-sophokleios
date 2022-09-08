defmodule TextServer.ExemplarJobRunner do
  use Oban.Worker

  alias TextServer.Exemplars

  # We can implement different actions by passing additional
  # args to Oban when adding an item to the queue
  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
  	exemplar = Exemplars.get_exemplar!(id)

  	IO.puts("ABOUT TO PARSE AN EXEMPLAR FROM THE QUEUE")
  	IO.inspect(exemplar)

  	parse(exemplar)
  end

 	defp parse(exemplar) do
 	  # parse exemplar, saving/updating TextNodes and TextElements
 	  case Exemplars.parse_exemplar(exemplar) do
 	  	{:ok, exemplar} ->
 	  		{:ok, exemplar}

 	  	{:error, reason} ->
 	  		IO.inspect(reason)
 	  		:error
 	  end
 	end
end
