# AOZ Voluntary Platform

master: [![Build Status](https://travis-ci.org/panter/aoz-003.svg?branch=master)](https://travis-ci.org/panter/aoz-003)
develop: [![Build Status](https://travis-ci.org/panter/aoz-003.svg?branch=develop)](https://travis-ci.org/panter/aoz-003)


Ruby version: 2.4.1

## Dependencies

- Postgresql
- [ImageMagick](http://www.imagemagick.org/) (for [paperclip](https://github.com/thoughtbot/paperclip))

## Developer Dependencies

- [overcommit](https://github.com/brigade/overcommit)
- [rubocop](https://github.com/bbatsov/rubocop)


## Setup Superadmin

Generate first superadmin with rails task
```bash
$ rails setup:superadmin email=email@test.com
```

## Create User

Create user in console
```bash
$ User.create(email: 'asdf1@asdf.com', password: 'asdfasdf', role: 'superadmin')
```

## Translations

use some `_('translations')`
run:
```bash
$ rake gettext:find [1]
$ rake gettext:store_model_attributes [2]
```
so as GetText to find all translations used [1]
and to parse db columns that can be translated (optional) [2].
Translate messages at `'locale/de/app.po'`.

More info: https://github.com/grosser/gettext_i18n_rails


## LICENSE

All the sources created are made available under the terms
of the GNU Affero General Public License (GNU AGPLv3).
See the GNU-AGPL-3.0.txt file for more details.
