[![Build Status](https://travis-ci.com/magpie-ea/magpie-backend.svg?branch=master)](https://travis-ci.com/magpie-ea/magpie-backend) [![Coverage Status](https://coveralls.io/repos/github/magpie-ea/magpie-backend/badge.svg?branch=master)](https://coveralls.io/github/magpie-ea/magpie-backend?branch=master)

- [Server Documentation](#server-documentation)
  - [Username and password for authentication](#username-and-password-for-authentication)
  - [Experiments](#experiments)
    - [Experiment creation](#experiment-creation)
    - [Dynamic experiments](#dynamic-experiments)
    - [Editing an experiment](#editing-an-experiment)
    - [Deactivating an experiment](#deactivating-an-experiment)
    - [Experiment Result submission via HTTP POST](#experiment-result-submission-via-http-post)
    - [Experiment results submission via Phoenix Channels](#experiment-results-submission-via-phoenix-channels)
    - [Experiment results retrieval as CSV](#experiment-results-retrieval-as-csv)
    - [Experiment results retrieval as JSON](#experiment-results-retrieval-as-json)
  - [Custom Data Records](#custom-data-records)
    - [Uploading a data record](#uploading-a-data-record)
    - [Retrieval of data records](#retrieval-of-data-records)
  - [Deploying the Server](#deploying-the-server)
    - [Deploying via Gigalixir](#deploying-via-gigalixir)
    - [Deploying via Fly.io](#deploying-via-flyio)
- [Experiments (Frontend)](#experiments-frontend)
- [Additional Notes](#additional-notes)
- [Development](#development)

This is a server backend to run psychological experiments in the browser. It
helps receive, store and retrieve data. It also provides communication channels for multi-participant interactive experiments.

A [live demo](https://magpie-demo.herokuapp.com/) of the app is available. Note that this demo doesn't require user authentication.

If you encounter any bugs during your experiments please [submit an issue](https://github.com/magpie-ea/magpie-backend/issues).

Please also refer to the [\_magpie project site](https://magpie-ea.github.io/magpie-site) and its [section on the server app](https://magpie-ea.github.io/magpie-site/serverapp/overview.html) for additional documentation.

Work on this project was funded via the project
[Pro^3](http://www.xprag.de/?page_id=4759), which is part of the [XPRAG.de](http://www.xprag.de/) funded by the German Research
Foundation (DFG Schwerpunktprogramm 1727).

# Server Documentation

This section documents the server program.

## Username and password for authentication

The app now comes with [Basic access Authentication](https://en.wikipedia.org/wiki/Basic_access_authentication). The username and password are set under `config :magpie, :authentication`.

For local development, the default username is `default` and the default password is `password`. You may change it in `dev.exs`.

If you're deploying on Heroku, be sure to set environment variables `AUTH_USERNAME` and `AUTH_PASSWORD`, either via Heroku command line tool or in the Heroku user interface, under `Settings` tab.

## Experiments

### Experiment creation

One can create a new experiment with the `New` button from the user interface. The experiment name and author are mandatory fields. You can create multiple experiments with the same name + author combination. The unique identifier generated by the database itself will differentiate them.

After an experiment is created, you can see its ID in the main user interface. Use this ID for results submission and retrieval.

### Dynamic experiments

Dynamic experiments are now supported via [Phoenix Channels](https://hexdocs.pm/phoenix/channels.html).

In a dynamic experiment, there is some sort of dependency between different generations. For example, the experiment might be iterative, in that the input of the next generation will be the output of the previous generation (e.g. iterated narration). Or the experiment might be interactive, in that multiple participants need to be present simultaneously to perform a task (e.g. a game of chess).

Each participant will be assigned a unique `<chain-nr, variant-nr, generation-nr, player-nr>` identifier, so that such dependencies could be made explicit.

The server is responsible for broadcasting messages between the participants. To make the backend as generic as possible, the specific interpretation and handling of the messages depend on the frontend client. For examples of frontends of dynamic experiments, please refer to: [1](https://github.com/magpie-ea/color-reference/) and [2](https://github.com/magpie-ea/iterated-experiment-example).

To create such an experiment, you need to specify the total number of chains, variants, and generations. Any positive integer is allowed.

The identifiers will be assigned incrementally in the order of `player-nr` -> `variant-nr` -> `chain-nr` -> `generation-nr`. Assuming the `<num-chains, num-variants, num-generations, num-players>` tuple is specified as `<2, 3, 10, 2>` at experiment creation, the participant who joins after the participant `<1, 1, 1, 1>` will be assigned the identifier `<1, 1, 1, 2>`, the participant who joins after `<2, 1, 2, 2>` will be assigned the identifier `<2, 2, 2, 1>`, etc.

A chain will reach its end when all generations have been submitted. The total number of expected participants is `num-chains * num-variants * num-generations * num-players`. For example, an iterated narration experiment might have 10 chains, 1 variant, 20 generations, 1 player (per round, since the experiment is not interactive), meaning that a total of 200 participants will be recruited.

Detailed descriptions can also be found at the experiment creation page.

### Editing an experiment

You can edit an experiment after its creation. However, note that at the moment the specifications of a complex experiment are not editable after experiment creation. You may create a new experiment instead.

### Deactivating an experiment

Once you don't want to receive any new submissions for a particular experiment, you can disable it via the edit interface by clicking on the `Edit` button.

### Experiment Result submission via HTTP POST

The server expects to receive a JSON **array** as the set of experiment results, via HTTP POST, at the address `{SERVER_ADDRESS}/api/submit_experiment/:id`, where `:id` is the unique experiment ID shown in the main user interface.

All objects of the array should contain a set of identical keys. Each object normally stands for one trial in the experiment, together with any additional information that is not associated with a particular trial, for example, the native language spoken by the participant.

<!-- Additionally, an optional array named `trial_keys_order`, which specifies the order in which the trial data should be -->
<!--  printed in the CSV output, can be included. If this array is not included, the trial data will be printed in alphabetical order, which might not be ideal. -->

[Here](https://jsfiddle.net/SZJX/Lg3vmk41/) you can find a minimal working example. The [Minimal Template](https://github.com/magpie-ea/MinimalTemplate) contains a full example experiment.

Note that to [POST a JSON object correctly](https://stackoverflow.com/questions/12693947/jquery-ajax-how-to-send-json-instead-of-querystring),
one needs to specify the `Content-Type` header as `application/json`, and use `JSON.stringify` to encode the data first.

Note that `crossDomain: true` is needed since the server domain will likely be different to the domain where the experiment is presented to the participant.

### Experiment results submission via Phoenix Channels

Since the client maintains a socket connection with the server in dynamic experiments, the submissions in such experiments are also expected to be performed via the socket. The server expects a `"submit_results"` message with a payload containing the `"results"` key. Examples: [1](https://github.com/magpie-ea/color-reference/) and [2](https://github.com/magpie-ea/iterated-experiment-example).

### Experiment results retrieval as CSV

Just press the button to the right of each row in the user interface.

### Experiment results retrieval as JSON

For some experiments, it might helpful to fetch and use data collected from previous experiment submissions in order to dynamically generate future trials. The \_magpie backend now provides this functionality.

For each experiment, you can specify the keys that should be fetched in the "Edit Experiment" user interface on the server app. Then, with a HTTP GET call to the `retrieve_experiment` endpoint, specifying the experiment ID, you will be able to get a JSON object that contains the results of that experiment so far.

`{SERVER_ADDRESS}/api/retrieve_experiment/:id`

A [minimal example](https://jsfiddle.net/SZJX/dp8ewnfx/) of frontend code using jQuery:

```javascript
$.ajax({
  type: 'GET',
  url: 'https://magpie-demo.herokuapp.com/api/retrieve_experiment/1',
  crossDomain: true,
  success: function(responseData, textStatus, jqXHR) {
    console.table(responseData);
  }
});
```

## Custom Data Records

Sometimes, it might be desirable to store custom data records on the server and later retrieve them for experiments, similar to the dynamic retrieval of previous experiment results. Now there is also an interface for it.

The type of each record is also JSON array of objects.

### Uploading a data record

The data record can be either:

- A CSV file containing the data to be stored in this record. The first row will be treated as the headers (keys). The file must have `.csv` extension.
- A JSON array of objects. The file must have `.json` extension.

The file can be chosen in the browser via the upload button.

If a data record is edited and a new file is uploaded, the old record will be overwritten.

### Retrieval of data records

Similar to experiment results, the data records can also be retrieved either as a CSV file via the browser or a JSON file via the API.

The JSON retrieval address is

`{SERVER_ADDRESS}/api/retrieve_custom_record/:id`

## Deploying the Server

This section documents some methods one can use to deploy the server.

### Deploying via Gigalixir

[Gigalixir](https://www.gigalixir.com) is a hosting service that offers a free tier. However, note that deploying the app once per month might be needed to avoid the app being temporarily shut down.

```
pip3 install gigalixir --user
gigalixir signup
gigalixir login
# Replace [your-app-name] with the desired name.
gigalixir create -n [your-app-name]
gigalixir pg:create --free
# Replace [your-app-name] with the desired name.
gigalixir config:set PHX_HOST=[your-app-name].gigalixirapp.com
gigalixir config:set PHX_SERVER=true
# Replace with your desired auth username and password.
gigalixir config:set AUTH_USERNAME=[your-auth-username]
gigalixir config:set AUTH_PASSWORD=[your-password]
git push -u gigalixir master
```

To deploy the app again after pulling in the latest updates:

```
git pull master
git push -u gigalixir master
```

To force deploy the app (e.g. once per month) even without any changes:

```
git commit --amend --no-edit
git push --force -u gigalixir master
```

### Deploying via Fly.io

[Fly.io](https://fly.io/) is a hosting service that remains free as long as the app's monthly usage remains below [the allowance](https://fly.io/docs/about/pricing/#free-allowances). However, credit card information is needed upon signup.


```
brew install flyctl
fly auth signup
fly auth login
# Do not proceed to deployment yet at the "whether to deploy" step.
fly launch
# Replace with your desired auth username and password.
fly secrets set AUTH_USERNAME=[your-auth-username]
fly secrets set AUTH_PASSWORD=[your-password]
fly deploy
```

To deploy the app again after pulling in the latest updates:

```
git pull master
fly deploy
```

# Experiments (Frontend)

This program is intended to serve as the backend which stores and returns experiment results. An experiment frontend is normally written as a set of static webpages to be hosted on a hosting provider (e.g. [Github Pages](https://pages.github.com/)) and loaded in the participant's browser.

For detailed documentation on the structure and deployment of experiments, please refer to the [departure point repo](https://github.com/magpie-ea/departure-point) and the [\_magpie documentation](https://magpie-ea.github.io/magpie-site/).

# Additional Notes

- When submitting experiment results, it is expected that each trial record does not contain any object or array among its **values**. The reason is that it would then be hard for the CSV writer to correctly format and produce a CSV file. In such cases, it is best to split experiment results into different keys containing simple values, e.g.

  ```js
  {
    "response1": "a",
    "response2": "b",
    "response3": "c",
    // ...
  }
  ```

  instead of

  ```js
  {
    "response": {"1": "a", "2": "b", "3": "c"},
    // or
    "response": ["a", "b", "c"]
    // ...
  }
  ```

  (However, currently if you actually submitted an object or array, the backend will still print it out, as it is. Good luck trying to parse that in your CSV output though!)

- There is limited guarantee on database reliability on Heroku's Hobby (free) grade. If the magpie-demo site for your experiments, you should retrieve the experiment results and perform backups as soon as possible.

# Development

- This app is based on Phoenix Framework and written in Elixir. The following links could be helpful for learning Elixir/Phoenix:
  - Official website: http://www.phoenixframework.org/
  - Guides: http://phoenixframework.org/docs/overview
  - Docs: https://hexdocs.pm/phoenix
  - Mailing list: http://groups.google.com/group/phoenix-talk
  - Source: https://github.com/phoenixframework/phoenix

To run the server app locally with `dev` environment, the following instructions could help. However, as the configuration of Postgres DB could be platform specific, relevant resources for [Postgres](https://www.postgresql.org/) could help.

1. Install Postgres. Ensure that you have version 9.2 or greater (for its JSON data type). You can check the version with the command `psql --version`.

2. Make sure that Postgres is correctly initialized as a service. If you installed it via Homebrew, the instructions should be shown on the command line. If you're on Linux, [the guide on Arch Linux Wiki](https://wiki.archlinux.org/index.php/PostgreSQL#Initial_configuration) could help.

3. Run `mix deps.get; mix ecto.create; mix ecto.migrate` in the app folder.

4. Run `mix assets.deploy` to deploy the frontend assets using `esbuild`.

5. Run `cd ..; mix phx.server` to run the server on `localhost:4000`.

6. Every time a database change is introduced with new migration files, run `mix ecto.migrate` again before starting the server.
