defmodule BABE.IteratedLobbyChannelTest do
  @moduledoc """
  Test for the iterated lobby channel
  """
  use BABE.ChannelCase

  alias BABE.ParticipantSocket
  alias BABE.IteratedLobbyChannel
  alias BABE.ChannelHelper
  alias BABE.ExperimentStatus

  setup do
    experiment = insert_complex_experiment()
    create_and_subscribe_participant(experiment)
  end

  test "joins the iterated lobby channel successfully", %{
    socket: socket,
    experiment: experiment,
    participant_id: participant_id
  } do
    assert {:ok, _, socket} =
             subscribe_and_join(
               socket,
               "iterated_lobby:#{experiment.id}:#{socket.assigns.variant}:#{socket.assigns.chain}:#{
                 socket.assigns.realization
               }"
             )
  end

  # test "successfully gets the experiment result if the corresponding ExperimentStatus is 2" do
  #   experiment_status =
  #     ChannelHelper.get_experiment_status(
  #       experiment_id,
  #       variant,
  #       chain,
  #       realization
  #     )

  #   experiment_status
  #   |> ExperimentStatus.changeset(%{status: 2})
  #   |> Repo.update!()

  #   # Still needs the helper method to populate reasonable experiment results before this can continue.
  # end
end
