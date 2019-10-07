defmodule Links.PbtTest do
  use ExUnit.Case
  use PropCheck

  property("always returns biggest item in the list") do
    forall x <- non_empty(list(integer())) do
      biggest(x) == List.last(Enum.sort(x))
    end
  end

  def biggest([head | tail]) do
    biggest(tail, head)
  end

  defp biggest([], max) do
    max
  end

  defp biggest([head | tail], max) when head >= max do
    biggest(tail, head)
  end

  defp biggest([head | tail], max) when head < max do
    biggest(tail, max)
  end

  property("chapter 2 exercise") do
    forall {start, count} <- {integer(), non_neg_integer()} do
      list = Enum.to_list(start..(start + count))
      count + 1 == length(list) and increments(list)
    end
  end

  def increments([head | tail]), do: increments(head, tail)

  defp increments(_, []), do: true

  defp increments(n, [head | tail]) when head == n + 1, do: increments(head, tail)

  defp increments(_, _), do: false
end
