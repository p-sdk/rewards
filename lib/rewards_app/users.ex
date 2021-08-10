defmodule RewardsApp.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias RewardsApp.Repo

  alias RewardsApp.Users.User

  @type t :: %User{}

  def list_members do
    from(User, where: [role: "member"])
    |> Repo.all()
  end

  def get_member!(id), do: Repo.get!(User, id)

  @spec create_admin(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create_admin(params) do
    %User{}
    |> User.changeset(params)
    |> User.changeset_role(%{role: "admin"})
    |> Repo.insert()
  end

  @spec set_admin_role(t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def set_admin_role(user) do
    user
    |> User.changeset_role(%{role: "admin"})
    |> Repo.update()
  end

  @spec is_admin?(t()) :: boolean()
  def is_admin?(%{role: "admin"}), do: true
  def is_admin?(_any), do: false
end
