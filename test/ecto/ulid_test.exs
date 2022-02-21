defmodule Ecto.ULIDTest do
  use ExUnit.Case, async: true

  @binary <<1, 95, 194, 60, 108, 73, 209, 114, 136, 236, 133, 115, 106, 195,
            145, 22>>
  @encoded "01BZ13RV29T5S8HV45EDNC748P"

  describe "type/0" do
    test "returns :uuid" do
      assert Ecto.ULID.type() == :uuid
    end
  end

  describe "generate/0" do
    test "generate/0 encodes milliseconds in first 10 characters" do
      # test case from ULID README: https://github.com/ulid/javascript#seed-time
      <<encoded::bytes-size(10), _rest::bytes-size(16)>> =
        Ecto.ULID.generate(1_469_918_176_385)

      assert encoded == "01ARYZ6S41"
    end

    test "generate/0 generates unique identifiers" do
      ulid1 = Ecto.ULID.generate()
      ulid2 = Ecto.ULID.generate()

      assert ulid1 != ulid2
    end
  end

  describe "bingenerate/0" do
    test "encodes milliseconds in first 48 bits" do
      now = System.system_time(:millisecond)
      <<time::48, _random::80>> = Ecto.ULID.bingenerate()

      assert_in_delta now, time, 10
    end

    test "generates unique identifiers" do
      ulid1 = Ecto.ULID.bingenerate()
      ulid2 = Ecto.ULID.bingenerate()

      assert ulid1 != ulid2
    end
  end

  # cast/1

  describe "cast/1" do
    test "returns valid ULID" do
      {:ok, ulid} = Ecto.ULID.cast(@encoded)
      assert ulid == @encoded
    end

    test "returns ULID for encoding of correct length" do
      {:ok, ulid} = Ecto.ULID.cast("00000000000000000000000000")
      assert ulid == "00000000000000000000000000"
    end

    test "returns error when encoding is too short" do
      assert Ecto.ULID.cast("0000000000000000000000000") == :error
    end

    test "returns error when encoding is too long" do
      assert Ecto.ULID.cast("000000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter I" do
      assert Ecto.ULID.cast("I0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter L" do
      assert Ecto.ULID.cast("L0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter O" do
      assert Ecto.ULID.cast("O0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter U" do
      assert Ecto.ULID.cast("U0000000000000000000000000") == :error
    end

    test "returns error for invalid encoding" do
      assert Ecto.ULID.cast("$0000000000000000000000000") == :error
    end
  end

  describe "cast!/1" do
    test "returns valid ULID" do
      assert Ecto.ULID.cast!(@encoded) == @encoded
    end

    test "returns error when encoding is too short" do
      assert_raise Ecto.CastError, fn ->
        Ecto.ULID.cast!("0000000000000000000000000")
      end
    end
  end

  describe "dump/1" do
    test "dumps valid ULID to binary" do
      {:ok, bytes} = Ecto.ULID.dump(@encoded)
      assert bytes == @binary
    end

    test "dumps encoding of correct length" do
      {:ok, bytes} = Ecto.ULID.dump("00000000000000000000000000")
      assert bytes == <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
    end

    test "returns error when encoding is too short" do
      assert Ecto.ULID.dump("0000000000000000000000000") == :error
    end

    test "returns error when encoding is too long" do
      assert Ecto.ULID.dump("000000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter I" do
      assert Ecto.ULID.dump("I0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter L" do
      assert Ecto.ULID.dump("L0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter O" do
      assert Ecto.ULID.dump("O0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter U" do
      assert Ecto.ULID.dump("U0000000000000000000000000") == :error
    end

    test "returns error for invalid encoding" do
      assert Ecto.ULID.dump("$0000000000000000000000000") == :error
    end
  end

  describe "load/1" do
    test "encodes binary as ULID" do
      {:ok, encoded} = Ecto.ULID.load(@binary)
      assert encoded == @encoded
    end

    test "encodes binary of correct length" do
      {:ok, encoded} =
        Ecto.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>)

      assert encoded == "00000000000000000000000000"
    end

    test "returns error when data is too short" do
      assert Ecto.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) ==
               :error
    end

    test "returns error when data is too long" do
      assert Ecto.ULID.load(
               <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
             ) ==
               :error
    end
  end

  describe "autogenerate/0" do
    test "returns a valid ULID" do
      ulid = Ecto.ULID.autogenerate()
      assert {:ok, ^ulid} = Ecto.ULID.cast(ulid)
    end
  end
end
