defmodule RewardsApp.UsersTest do
  use RewardsApp.DataCase
  import RewardsApp.Fixtures
  alias RewardsApp.{Repo, Users, Users.User}

  @valid_params %{
    name: "User",
    email: "test@example.com",
    password: "secret1234",
    password_confirmation: "secret1234"
  }

  describe "members" do
    test "list_members/0 returns all members" do
      member = user_fixture()

      assert {:ok, _admin} =
               Users.create_admin(%{@valid_params | name: "Admin", email: "admin@example.com"})

      assert Users.list_members() == [member]
    end

    test "get_member!/1 returns the member with given id" do
      member = user_fixture()
      assert Users.get_member!(member.id) == member
    end
  end

  describe "admins" do
    test "create_admin/1" do
      assert {:ok, user} = Users.create_admin(@valid_params)
      assert user.role == "admin"
    end

    test "set_admin_role/1" do
      assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
      assert user.role == "member"

      assert {:ok, user} = Users.set_admin_role(user)
      assert user.role == "admin"
    end

    test "is_admin?/1" do
      refute Users.is_admin?(nil)

      assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
      refute Users.is_admin?(user)

      assert {:ok, admin} = Users.create_admin(%{@valid_params | name: "Admin", email: "test2@example.com"})
      assert Users.is_admin?(admin)
    end
  end
end
