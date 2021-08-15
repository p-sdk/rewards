defmodule RewardsApp.Email do
  use Bamboo.Phoenix, view: RewardsAppWeb.EmailView

  def reward_created_email(reward) do
    reward = RewardsApp.Repo.preload(reward, [:receiver, pool: :owner])

    new_email()
    |> from({"RewardsApp", from_address()})
    |> to(reward.receiver)
    |> subject("You got a reward!")
    |> assign(:sender, reward.pool.owner)
    |> assign(:points, reward.points)
    |> render(:reward_created)
  end

  defp from_address() do
    Application.get_env(:rewards_app, __MODULE__)[:mail_from_address]
  end
end
