defmodule ExBanking do
  @moduledoc """
  Main Module to interact with the banking application
  """

  alias ExBanking.User
  alias ExBanking.UserSupervisor

  @doc """
  This function will create a user process to save currency and amount
  Example
  iex> ExBanking.create_user("user")
  :ok
  """
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    case UserSupervisor.new_user(user) do
      {:ok, _pid} -> :ok
      error -> error
    end
  end

  def create_user(_user), do: {:error, :wrong_arguments}

  @doc """
  This function will deposit money to a user process
  Example
  iex> ExBanking.deposit("user", 5, "usd")
  {:ok, 5.0}
  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency)
      when is_binary(user) and is_integer(amount) and amount >= 0 and is_binary(currency) do
    User.request(user, {:deposit, amount, currency})
  end

  def deposit(_user, _amount, _currency), do: {:error, :wrong_arguments}

  @doc """
  This function will withdraw money from a user process
  Example
  iex> ExBanking.withdraw("user", 5, "usd")
  {:ok, 0.0}
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency)
      when is_binary(user) and is_integer(amount) and amount >= 0 and is_binary(currency) do
    User.request(user, {:withdraw, amount, currency})
  end

  def withdraw(_user, _amount, _currency), do: {:error, :wrong_arguments}

  @doc """
  This function will return current balance from a user process for a particular currency
  Example
  iex> ExBanking.get_balance("user", "usd")
  {:ok, 5.0}
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    User.request(user, {:get_balance, currency})
  end

  def get_balance(_, _), do: {:error, :wrong_arguments}

  @doc """
  This function will send money from a user process to a another user process
  Example
  iex> ExBanking.send("sender", "receiver", 5, "usd")
  {:ok, 5.0, 5.0}
  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number, to_user_balance :: number}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency)
      when is_binary(from_user) and is_binary(to_user) and is_integer(amount) and amount >= 0 and
             is_binary(currency) do
    opts = [
      user_exist_error_msg: :sender_does_not_exist,
      requests_limit_error_msg: :too_many_requests_to_sender
    ]

    User.request(from_user, {:send, to_user, amount, currency}, opts)
  end

  def send(_from_user, _to_user, _amount, _currency), do: {:error, :wrong_arguments}
end
