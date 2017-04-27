# AOZ Voluntary Platform

[master](https://github.com/panter/aoz-003/tree/master): [![Build Status](https://travis-ci.org/panter/aoz-003.svg?branch=master)](https://travis-ci.org/panter/aoz-003) |
[develop](https://github.com/panter/aoz-003): [![Build Status](https://travis-ci.org/panter/aoz-003.svg?branch=develop)](https://travis-ci.org/panter/aoz-003)

Ruby version: 2.4.1

## Dependencies

- Postgresql
- [ImageMagick](http://www.imagemagick.org/) (for [paperclip](https://github.com/thoughtbot/paperclip))

## Developer Dependencies

- [overcommit](https://github.com/brigade/overcommit)
- [rubocop](https://github.com/bbatsov/rubocop)

## User seeds for development

Use `rails db:seed` to get these users:

- superadmin
  - email: superadmin@example.com
  - password: asdfasdf
- admin
  - email: admin@example.com
  - password: asdfasdf
- social_worker
  - email: social_worker@example.com
  - password: asdfasdf

## LICENSE

All the sources created are made available under the terms
of the GNU Affero General Public License (GNU AGPLv3).
See the GNU-AGPL-3.0.txt file for more details.
