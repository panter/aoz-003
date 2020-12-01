# AOZ Voluntary Platform

## Pipeline Status

- Develop: [![pipeline status](https://git.panter.ch/open-source/aoz-003/badges/develop/pipeline.svg)](https://git.panter.ch/open-source/aoz-003/commits/develop)
- Main: [![pipeline status](https://git.panter.ch/open-source/aoz-003/badges/main/pipeline.svg)](https://git.panter.ch/open-source/aoz-003/commits/main)

Ruby version: 2.4.2

## Table of content

* [AOZ Voluntary Platform](#aoz-voluntary-platform)
  * [Pipeline Status](#pipeline-status)
  * [Table of content](#table-of-content)
    * [Dependencies](#dependencies)
    * [Developer Dependencies](#developer-dependencies)
    * [User seeds for development](#user-seeds-for-development)
    * [Create initial superadmin account](#create-initial-superadmin-account)
    * [Sort locale yaml files](#sort-locale-yaml-files)
    * [Run model, integration and controller tests](#run-model-integration-and-controller-tests)
    * [Run system (acceptance) tests](#run-system-acceptance-tests)
    * [LICENSE](#license)

### Dependencies

- Postgresql
- [ImageMagick](http://www.imagemagick.org/) (for [paperclip](https://github.com/thoughtbot/paperclip))

### Developer Dependencies

- [overcommit](https://github.com/brigade/overcommit)
- [rubocop](https://github.com/bbatsov/rubocop)

### User seeds for development

Use `rails db:seed` to get these users:

- superadmin
  - email: superadmin@example.com
  - password: asdfasdf
- social_worker
  - email: social_worker@example.com
  - password: asdfasdf
- department_manager
  - email: department_manager@example.com
  - password: asdfasdf
- volunteer
  - email: volunteer@example.com
  - password: asdfasdf

### Create initial superadmin account

Sends an invitation email to the email address, so that the account can be activated:

```bash
$  rails setup:superadmin email=email@test.com
```

Ready to use with standard Password `asdfasdf` (No activation needed):

**Only use this on testing servers that are unable to send emails (_security risk_)**

```bash
$  rails setup:superadmin_initialized email=email@test.com
```

### Sort locale yaml files

Run this task, in order to sort the locale files alphabetically.

```bash
$  rails i18n:sort
```

### Run model, integration and controller tests

```bash
$ rails test
```

### Run system (acceptance) tests

For system (acceptance) tests run:

```bash
$ rails test:system
```

For having chrome open and visible when running system tests locally:

```bash
$ rails test:system driver=visible
```

### LICENSE

All the sources created are made available under the terms
of the GNU Affero General Public License (GNU AGPLv3).
See the GNU-AGPL-3.0.txt file for more details.
