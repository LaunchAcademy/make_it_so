# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- add @types/jest for VSCode intellisense

## [0.5.1] - 2019-10-08

- skip bootsnap by default
- added prerequisite rails version check
- adjust webpacker routines to run `after_bundle`
- only stop spring if it is being installed

## [0.5.0] - 2019-09-02

### Added

- `react-router` is now installed by default

### Changed

- `--karma` and `--jest` options have been removed in favor of a `--js-test-lib` param. 
- The default behavior of `make_it_so` now generates `jest` as the default test lib instead of `karma`
- `foundation-rails` was updated to v6.5
- `modernizr` was removed
- Development runtime was upgraded to ruby v2.6.3

[Unreleased]:https://github.com/LaunchAcademy/make_it_so/compare/v0.5.0...HEAD
[0.5.1]:https://github.com/LaunchAcademy/make_it_so/compare/v0.5.0...v0.5.1
[0.5.0]:https://github.com/LaunchAcademy/make_it_so/compare/v0.4.5...v0.5.0