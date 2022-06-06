defmodule TextServer.Texts do
  @moduledoc """
  The Texts context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  def repositories do
    [
      # %{
      #   title: "The Center for Hellenic Studies Greek Texts",
      #   url: "http://gitlab.archimedes.digital/archimedes/greek_text_chs",
      #   urn: "urn:cts:greekLit"
      #   default_language: "greek"
      # },
      %{
        title: "The First Thousand Years of Greek",
        url: "https://github.com/OpenGreekAndLatin/First1KGreek.git",
        urn: "urn:cts:greekLit"
      },
      %{
        title: "Canonical Greek Literature",
        url: "https://github.com/PerseusDL/canonical-greekLit.git",
        urn: "urn:cts:greekLit"
      },
      %{
        title: "Canonical Latin Literature",
        url: "https://github.com/PerseusDL/canonical-latinLit.git",
        urn: "urn:cts:latinLit"
      },
      %{
        title: "Corpus Scriptorum Ecclesiasticorum Latinorum",
        url: "https://github.com/OpenGreekAndLatin/csel-dev.git",
        urn: "urn:cts:latinLit"
      },
      %{
        title: "Tanzil Quran Text",
        url: "https://github.com/cltk/arabic_text_quranic_corpus.git",
        default_language: "arabic"
      },
      %{
        title: "Sefaria Jewish Texts",
        url: "https://github.com/cltk/hebrew_text_sefaria.git",
        default_language: "hebrew"
      },
      %{
        title: "Gita Supersite",
        url: "https://github.com/cltk/sanskrit_text_gitasupersite.git",
        default_language: "sanskrit"
      },
      %{
        title: "Classical Bengali Texts",
        url: "https://github.com/cltk/bengali_text_wikisource.git",
        default_language: "bengali"
      },
      %{
        title: "Classical Hindi Texts",
        url: "https://github.com/cltk/hindi_text_ltrc.git",
        default_language: "hindi"
      },
      %{
        title: "Corpus of Middle English Prose and Verse",
        url: "https://github.com/cltk/middle_english_text_cmepv.git",
        default_language: "middle_english"
      },
      %{
        title: "Poeti d'Italia in lingua latina",
        url: "https://github.com/cltk/latin_text_poeti_ditalia.git",
        default_language: "latin"
      },
      %{
        title: "Canonical Old Norse Literature",
        url: "https://github.com/cltk/old_norse_text_perseus.git",
        default_language: "old_norse"
      },
      %{
        title: "Old English Poetry",
        url: "https://github.com/cltk/old_english_text_sacred_texts.git",
        default_language: "old_english"
      },
      %{
        title: "Chinese Buddhist Electronic Text Association 01",
        url: "https://github.com/cltk/chinese_text_cbeta_01.git",
        default_language: "chinese"
      }
    ]
  end
end
