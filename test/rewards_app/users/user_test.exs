defmodule RewardsApp.Users.UserTest do
  use RewardsApp.DataCase

  alias RewardsApp.Users.User

  test "changeset/2 sets default role" do
    user =
      %User{}
      |> User.changeset(%{})
      |> Ecto.Changeset.apply_changes()

    assert user.role == "member"
  end

  test "changeset_role/2" do
    changeset = User.changeset_role(%User{}, %{role: "invalid"})

    assert changeset.errors[:role] ==
             {"is invalid", [validation: :inclusion, enum: ["member", "admin"]]}

    changeset = User.changeset_role(%User{}, %{role: "admin"})
    refute changeset.errors[:role]
  end
end
