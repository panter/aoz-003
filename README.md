# AOZ Voluntary Platform

[master](https://github.com/panter/aoz-003/tree/master): [![Build Status](https://travis-ci.org/panter/aoz-003.svg?branch=master)](https://travis-ci.org/panter/aoz-003) |
[develop](https://github.com/panter/aoz-003): [![Build Status](https://travis-ci.org/panter/aoz-003.svg?branch=develop)](https://travis-ci.org/panter/aoz-003)

Ruby version: 2.4.1

## Table of content

1. [Dependencies](#dependencies)
1. [Developer Dependencies](#developer-dependencies)
1. [User seeds for development](#user-seeds-for-development)
1. [Create initial superadmin account](#create-initial-superadmin-account)
1. [Sort locale yaml files](#sort-locale-yaml-files)
1. [Importing from access db with rake task](#importing-from-access-db-with-rake-task)
1. [LICENSE](#license)

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

### Create initial superadmin account

Sends a invitaion email to the email address, so that the account can be activated:

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

### Importing from access db with rake task

Run in the command line:

```bash
$  rails access:import file=path/to/access_file.accdb
```

### LICENSE

All the sources created are made available under the terms
of the GNU Affero General Public License (GNU AGPLv3).
See the GNU-AGPL-3.0.txt file for more details.
