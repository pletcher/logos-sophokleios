defmodule TextServer.TextNodes.TextNodeRope do
  # NOTE: (charles) This module isn't being used at the moment.
  # I'm not sure if it will become necessary: it's good for thinking
  # about the fundamentals of the text editor, but we don't
  # have the resources to build and maintain our own custom
  # implementation. We should look into something like
  # https://tiptap.dev/api/nodes or even ProseMirror directly

  # see https://github.com/copenhas/ropex/blob/master/lib/rope.ex
  defmodule Leaf do
    defstruct [:offset, :tags, :value]

    @type t :: %__MODULE__{
      offset: non_neg_integer(),
      tags: [atom()],
      value: String.t()
    }
  end

  defmodule Node do
    defstruct [
      :left,
      :offset,
      :right
    ]

    @type t :: %__MODULE__{
      left: TextNodeRope.t(),
      offset: non_neg_integer(),
      right: TextNodeRope.t()
    }
  end

  @type t :: Leaf.t() | Node.t() | nil
end
