defmodule NamedEntities.PausaniasEng do
  def serving do
    {:ok, model_info} =
      Bumblebee.load_model(
        {:local,
         to_string(:code.priv_dir(:text_server)) <> "/language_models/dslim/bert-base-NER"}
      )

    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "bert-base-cased"})

    Bumblebee.Text.token_classification(model_info, tokenizer, aggregation: :same)
  end
end
