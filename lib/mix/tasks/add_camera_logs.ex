defmodule EvercamMedia.AddCameraLogs do
  import Ecto.Query
  import Ecto.Changeset
  import CameraActivity, only: [changeset: 2, get_last_on_off_log: 1]
  alias EvercamMedia.Repo
  alias EvercamMedia.SnapshotRepo
  require Logger

  def run do
    {:ok, _} = Application.ensure_all_started(:evercam_media)

    Camera
    |> Repo.all
    |> Enum.each(fn(camera) ->
      case get_last_on_off_log(camera.id) do
        nil ->
          add_log_for_camera(camera.is_online, camera)
          Logger.info "Log has been added for Camera: #{camera.exid}, Status: #{camera.is_online}."
        %CameraActivity{done_at: done_at, action: action} ->
          case action == humanize_status(camera.is_online) do
            true ->
              Logger.info "Log is already present for camera: #{camera.exid}."
            false ->
              add_log_against_action(action, camera.is_online, done_at, camera)
              Logger.info "Log Added for Camera: #{camera.exid}, Action: #{action}, Status: #{camera.is_online}"
          end
      end
    end)
  end

  defp add_log_against_action("online", false, _done_at, camera) do
    pass_values_to_db("offline", camera.last_online_at, camera)
  end
  defp add_log_against_action("offline", true, done_at, camera) do
    pass_values_to_db("online", done_at_after_two_minutes(done_at), camera)
  end

  defp done_at_after_two_minutes(done_at) do
    done_at
    |> Ecto.DateTime.to_erl
    |> :calendar.datetime_to_gregorian_seconds
    |> Kernel.+(60 * 2)
    |> :calendar.gregorian_seconds_to_datetime
    |> Ecto.DateTime.from_erl
  end

  defp pass_values_to_db(action, done_at, camera) do
    params = %{
      camera_id: camera.id,
      camera_exid: camera.exid,
      action: action,
      done_at: done_at
    }
    %CameraActivity{}
    |> changeset(params)
    |> SnapshotRepo.insert
  end

  defp add_log_for_camera(false, camera), do: pass_values_to_db("offline", camera.last_online_at, camera)
  defp add_log_for_camera(true, _camera), do: :noop

  defp humanize_status(true), do: "online"
  defp humanize_status(false), do: "offline"
end
