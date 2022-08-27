defmodule Til.Gravatar do
  @spec url(String.t()) :: String.t()
  def url(email) do
    email_hash =
      email
      |> String.trim()
      |> String.downcase()
      |> hash()

    "https://www.Gravatar.com/avatar/#{email_hash}.png"
  end

  defp hash(str), do: :crypto.hash(:md5, str) |> Base.encode16(case: :lower)
end
