defmodule EvercamMedia.ModelCase do
  @moduledoc """
  This module defines the test case to be used by
  model tests.

  You may define functions here to be used as helpers in
  your model tests. See `errors_on/2`'s definition as reference.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias EvercamMedia.Repo
      alias EvercamMedia.SnapshotRepo
      # import Ecto.Model
      import Ecto.Query, only: [from: 2]
    end
  end

  setup do
    # Wrap this case in a transaction
    Ecto.Adapters.SQL.Sandbox.checkout(EvercamMedia.Repo)
    Ecto.Adapters.SQL.Sandbox.checkout(EvercamMedia.SnapshotRepo)
    EvercamMedia.TestHelpers.invalidate_caches

    :ok
  end

  @doc """
  Helper for returning list of errors in model when passed certain data.

  ## Examples

  Given a User model that lists `:name` as a required field and validates
  `:password` to be safe, it would return:

  iex> errors_on(%User{}, password: "password")
  [password: "is unsafe", name: "is blank"]

  You could then write your assertion like:

  assert {:password, "is unsafe"} in errors_on(%User{}, password: "password")

  You can also create the changeset manually and retrieve the errors
  field directly:

  iex> changeset = User.changeset(%User{}, password: "password")
  iex> {:password, "is unsafe"} in changeset.errors
  true
  """
  def errors_on(model, data) do
    model.__struct__.changeset(model, data).errors
  end
end
