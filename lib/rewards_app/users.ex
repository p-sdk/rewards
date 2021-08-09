defmodule RewardsApp.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias RewardsApp.Repo

  alias RewardsApp.Users.User

  def list_members do
    Repo.all(User)
  end

  def get_member!(id), do: Repo.get!(User, id)
end
