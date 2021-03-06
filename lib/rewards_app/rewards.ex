defmodule RewardsApp.Rewards do
  @moduledoc """
  The Rewards context.
  """

  import Ecto.Query, warn: false
  alias RewardsApp.Repo

  alias RewardsApp.Rewards.{Pool, Reward}

  def list_periods() do
    from(p in Pool,
      distinct: [desc: :year, desc: :month],
      order_by: [desc: :year, desc: :month],
      select: %{month: p.month, year: p.year}
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of pools.

  ## Examples

      iex> list_pools()
      [%Pool{}, ...]

  """
  def list_pools do
    Repo.all(Pool)
  end

  def list_pools_for(member) do
    from(Pool,
      where: [owner_id: ^member.id],
      order_by: [desc: :year, desc: :month]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single pool.

  Raises `Ecto.NoResultsError` if the Pool does not exist.

  ## Examples

      iex> get_pool!(123)
      %Pool{}

      iex> get_pool!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pool!(id), do: Repo.get!(Pool, id)

  def get_or_create_current_pool_for(member) do
    %{month: month, year: year} = DateTime.utc_now()
    get_or_create_pool_for(member, month, year)
  end

  def get_or_create_pool_for(owner, month, year) do
    %Pool{owner_id: owner.id, month: month, year: year}
    |> change_pool(%{})
    |> Repo.insert()
    |> case do
      {:ok, pool} ->
        pool

      {:error, changeset} ->
        %{owner_id: owner_id, month: month, year: year} = changeset.data
        Repo.get_by!(Pool, owner_id: owner_id, month: month, year: year)
    end
  end

  def get_pool_with_rewards_and_receivers(id) do
    from(Pool,
      where: [id: ^id],
      preload: [rewards: ^{from(Reward, order_by: [desc: :id]), [:receiver]}]
    )
    |> Repo.one()
  end

  @doc """
  Creates a pool.

  ## Examples

      iex> create_pool(%{field: value})
      {:ok, %Pool{}}

      iex> create_pool(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pool(attrs \\ %{}) do
    %Pool{}
    |> Pool.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pool.

  ## Examples

      iex> update_pool(pool, %{field: new_value})
      {:ok, %Pool{}}

      iex> update_pool(pool, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pool(%Pool{} = pool, attrs) do
    pool
    |> Pool.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pool.

  ## Examples

      iex> delete_pool(pool)
      {:ok, %Pool{}}

      iex> delete_pool(pool)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pool(%Pool{} = pool) do
    Repo.delete(pool)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pool changes.

  ## Examples

      iex> change_pool(pool)
      %Ecto.Changeset{data: %Pool{}}

  """
  def change_pool(%Pool{} = pool, attrs \\ %{}) do
    Pool.changeset(pool, attrs)
  end

  @doc """
  Returns the list of rewards.

  ## Examples

      iex> list_rewards()
      [%Reward{}, ...]

  """
  def list_rewards do
    Repo.all(Reward)
  end

  def list_rewards_recently_given_by(%{id: member_id} = _member) do
    %{month: month, year: year} = Date.utc_today()

    from(r in Reward,
      join: p in assoc(r, :pool),
      where: p.owner_id == ^member_id,
      where: p.month == ^month and p.year == ^year,
      order_by: [desc: :id],
      preload: :receiver
    )
    |> Repo.all()
  end

  def get_rewards_summary(month, year) do
    from(r in Reward,
      join: p in assoc(r, :pool),
      join: u in assoc(r, :receiver),
      where: p.month == ^month and p.year == ^year,
      group_by: u.id,
      select: %{name: u.name, points: sum(r.points)},
      order_by: [desc: sum(r.points)]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single reward.

  Raises `Ecto.NoResultsError` if the Reward does not exist.

  ## Examples

      iex> get_reward!(123)
      %Reward{}

      iex> get_reward!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reward!(id), do: Repo.get!(Reward, id)

  @doc """
  Creates a reward.

  ## Examples

      iex> create_reward(%{field: value})
      {:ok, %Reward{}}

      iex> create_reward(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reward(attrs \\ %{}) do
    reward = Reward.changeset(%Reward{}, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:reward, reward)
    |> Ecto.Multi.update(:pool, fn %{reward: reward} ->
      pool = get_pool!(reward.pool_id)
      remaining_points = pool.remaining_points - reward.points
      Pool.changeset(pool, %{remaining_points: remaining_points})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{reward: reward}} -> {:ok, reward}
      {:error, :reward, changeset, _} -> {:error, changeset}
      {:error, :pool, _, _} -> {:error, :points_too_high}
    end
  end

  def create_reward(sender, receiver, points) do
    pool = get_or_create_current_pool_for(sender)
    attrs = %{points: points, pool_id: pool.id, receiver_id: receiver.id}
    create_reward(attrs)
  end

  @doc """
  Updates a reward.

  ## Examples

      iex> update_reward(reward, %{field: new_value})
      {:ok, %Reward{}}

      iex> update_reward(reward, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reward(%Reward{} = reward, attrs) do
    reward
    |> Reward.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reward.

  ## Examples

      iex> delete_reward(reward)
      {:ok, %Reward{}}

      iex> delete_reward(reward)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reward(%Reward{} = reward) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:reward, reward)
    |> Ecto.Multi.update(:pool, fn %{reward: reward} ->
      pool = get_pool!(reward.pool_id)
      remaining_points = pool.remaining_points + reward.points
      Pool.changeset(pool, %{remaining_points: remaining_points})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{reward: reward}} -> {:ok, reward}
      {:error, _, _, _} -> :error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reward changes.

  ## Examples

      iex> change_reward(reward)
      %Ecto.Changeset{data: %Reward{}}

  """
  def change_reward(%Reward{} = reward, attrs \\ %{}) do
    Reward.changeset(reward, attrs)
  end
end
