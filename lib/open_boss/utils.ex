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

  @spec browser_time_to_dt(String.t(), String.t()) :: DateTime.t() | nil
  def browser_time_to_dt("", _timezone), do: nil

  def browser_time_to_dt(time, timezone) do
    NaiveDateTime.from_iso8601!(time <> ":00Z") |> DateTime.from_naive!(timezone)
  end

  @spec dt_to_browser_time(DateTime.t(), String.t()) :: NaiveDateTime.t()
  def dt_to_browser_time(dt, browser_timezone) do
    DateTime.shift_zone!(dt, browser_timezone) |> DateTime.to_naive()
  end

  @spec dt_to_browser_time_string(DateTime.t(), String.t()) :: String.t()
  def dt_to_browser_time_string(dt, browser_timezone) do
    dt_to_browser_time(dt, browser_timezone)
    |> NaiveDateTime.truncate(:second)
    |> NaiveDateTime.to_string()
  end
end
