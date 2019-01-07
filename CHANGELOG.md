# Changelog

## Newest
### Fixed
- Allow socket connection from any host, since we don't constrain where the user hosts the frontend _babe experiment.

## [0.2.0] - 2018-01-05
### Added
- <variant-nr, chain-nr, realization-nr> based complex experiment mechanism, using Phoenix Channels.

### Removed
- `:maximum_submissions` column from `:experiments` table. There is no need to automatically deactivate an experiment.
- `:current_submissions` column from `:experiments` table. The number of submissions is now directly counted from the DB.
- `:is_interactive_experiment` and `:num_participants_interactive_experiment` columns from `:experiments` table. The previous interactive experiment mechanism is now replaced by the tritupled-based complex experiment mechanism.

### Fixed
- A bug where if the `{author_name, experiment_name}` of two experiments are completely the same, the results cannot be downloaded properly.