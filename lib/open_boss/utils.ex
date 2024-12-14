defmodule OpenBoss.Utils do
  @moduledoc """
  Utilities
  """

  @spec celsius_to_farenheit(float() | nil) :: float() | nil
  def celsius_to_farenheit(nil), do: nil
  def celsius_to_farenheit(c), do: c * 1.8 + 32.0

  @spec farenheit_to_celsius(float() | nil) :: float() | nil
  def farenheit_to_celsius(nil), do: nil
  def farenheit_to_celsius(f), do: (f - 32.0) / 1.8

  @spec safe_round(float() | nil) :: integer() | nil
  def safe_round(nil), do: nil
  def safe_round(val), do: round(val)

  @spec display_temp(celsius :: float() | nil) :: String.t()
  def display_temp(nil), do: "-"

  def display_temp(celsius) do
    "#{celsius_to_farenheit(celsius) |> round()}\u00b0F / #{round(celsius)}\u00b0C"
  end
end
