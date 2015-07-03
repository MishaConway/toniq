# Listens for new jobs and sends them to workers.

# TODO: not entierly sure how to test this yet besides the full integration test

defmodule Exqueue.JobSubscriber do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: :job_subscriber)
  end

  def init(args) do
    start_subscribing_for_jobs
    start_polling_for_jobs
    {:ok, []}
  end

  def handle_cast(:job_added, state) do
    look_for_new_jobs
    {:noreply, state}
  end

  defp start_subscribing_for_jobs do
    spawn_link fn ->
      Exqueue.Peristance.subscribe_to_new_jobs
      wait_for_new_jobs
    end
  end

  defp start_polling_for_jobs do
    spawn_link &poll_for_jobs/0
  end

  defp wait_for_new_jobs do
    receive do
      :job_added ->
        Process.whereis(:job_subscriber)
        |> GenServer.cast(:job_added)
    end

    wait_for_new_jobs
  end

  defp poll_for_jobs do
    look_for_new_jobs
    :timer.sleep(1000)
    poll_for_jobs
  end

  defp look_for_new_jobs do
    IO.inspect "TODO: look for new jobs"
  end
end
