defmodule Magpie.Experiments.SlotsTest do
  @moduledoc false

  use Magpie.ModelCase

  alias Magpie.Experiments.Slots

  describe "generate_slots_from_ulc_specification/1" do
    test "generates slot specs correctly" do
      tuple_spec = %{
        num_variants: 2,
        num_chains: 2,
        num_generations: 2,
        num_players: 2
      }

      slot_ordering = [
        "1_1:1:1:1",
        "1_1:1:1:2",
        "1_1:1:2:1",
        "1_1:1:2:2",
        "1_1:2:1:1",
        "1_1:2:1:2",
        "1_1:2:2:1",
        "1_1:2:2:2",
        "1_2:1:1:1",
        "1_2:1:1:2",
        "1_2:1:2:1",
        "1_2:1:2:2",
        "1_2:2:1:1",
        "1_2:2:1:2",
        "1_2:2:2:1",
        "1_2:2:2:2"
      ]

      slot_statuses = %{
        "1_1:1:1:1" => "hold",
        "1_1:1:1:2" => "hold",
        "1_1:1:2:1" => "hold",
        "1_1:1:2:2" => "hold",
        "1_1:2:1:1" => "hold",
        "1_1:2:1:2" => "hold",
        "1_1:2:2:1" => "hold",
        "1_1:2:2:2" => "hold",
        "1_2:1:1:1" => "hold",
        "1_2:1:1:2" => "hold",
        "1_2:1:2:1" => "hold",
        "1_2:1:2:2" => "hold",
        "1_2:2:1:1" => "hold",
        "1_2:2:1:2" => "hold",
        "1_2:2:2:1" => "hold",
        "1_2:2:2:2" => "hold"
      }

      slot_dependencies = %{
        "1_1:1:1:1" => [],
        "1_1:1:1:2" => [],
        "1_1:1:2:1" => ["1_1:1:1:2", "1_1:1:1:1"],
        "1_1:1:2:2" => ["1_1:1:1:2", "1_1:1:1:1"],
        "1_1:2:1:1" => [],
        "1_1:2:1:2" => [],
        "1_1:2:2:1" => ["1_1:2:1:2", "1_1:2:1:1"],
        "1_1:2:2:2" => ["1_1:2:1:2", "1_1:2:1:1"],
        "1_2:1:1:1" => [],
        "1_2:1:1:2" => [],
        "1_2:1:2:1" => ["1_2:1:1:2", "1_2:1:1:1"],
        "1_2:1:2:2" => ["1_2:1:1:2", "1_2:1:1:1"],
        "1_2:2:1:1" => [],
        "1_2:2:1:2" => [],
        "1_2:2:2:1" => ["1_2:2:1:2", "1_2:2:1:1"],
        "1_2:2:2:2" => ["1_2:2:1:2", "1_2:2:1:1"]
      }

      assert {slot_ordering, slot_statuses, slot_dependencies} ==
               Slots.generate_slots_from_ulc_specification(tuple_spec)
    end
  end
end
