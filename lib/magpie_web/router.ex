defmodule Magpie.Router do
  use MagpieWeb, :router
  use Plug.ErrorHandler

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", Magpie do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    # No need for :show as this is currently already covered by :edit
    resources("/experiments", ExperimentController, except: [:show])

    # A special endpoint only for activating/deactivating an experiment
    get("/experiments/:id/toggle", ExperimentController, :toggle)
    # Special endpoint for resetting an experiment
    delete("/experiments/:id/reset", ExperimentController, :reset)

    get("/experiments/:id/retrieve", ExperimentController, :retrieve_as_csv)

    # get "/custom_records", CustomRecordController, :index
    resources("/custom_records", CustomRecordController, except: [:show])
    get("/custom_records/:id/retrieve", CustomRecordController, :retrieve_as_csv)
  end

  scope "/api", Magpie do
    pipe_through(:api)

    # Maybe it would have been better to also follow the POST naming conventions in the API, but now that the frontend code is already out there, better not change it I guess.
    post("/submit_experiment/:id/", ExperimentController, :submit)
    get("/retrieve_experiment/:id/", ExperimentController, :retrieve_as_json)
    get("/retrieve_assignment/:assignment_identifier", ExperimentController, :retrieve_assignment)
    get("/retrieve_custom_record/:id/", CustomRecordController, :retrieve_as_json)
    get("/check_experiment/:id/", ExperimentController, :check_valid)

    get("/report_heartbeat/:assignment_identifier", ExperimentController, :report_heartbeat)
  end
end
