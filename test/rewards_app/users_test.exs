defmodule RewardsApp.UsersTest do
  use RewardsApp.DataCase
  import RewardsApp.Fixtures
  alias RewardsApp.Users

  describe "members" do
    test "list_members/0 returns all members" do
      member = user_fixture()
      assert Users.list_members() == [member]
    end

    test "get_member!/1 returns the member with given id" do
      member = user_fixture()
      assert Users.get_member!(member.id) == member
    end
  end
end
