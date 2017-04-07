# AOZ Voluntary Platform

master: [![Build Status](https://travis-ci.org/panter/aoz-003.svg?branch=master)](https://travis-ci.org/panter/aoz-003)
develop: [![Build Status](https://travis-ci.org/panter/aoz-003.svg?branch=develop)](https://travis-ci.org/panter/aoz-003)


Ruby version: 2.4.1

## Dependencies

- Postgresql

## Developer Dependencies

- [overcommit](https://github.com/brigade/overcommit)
- [rubocop](https://github.com/bbatsov/rubocop)
- [PhantomJS](http://phantomjs.org/download.html)

### Install PhantomJS

*MacOS with Homebrew*: `brew install phantomjs`
*Debian (and similars):* 'apt-get install phantomjs'
*Download and install manually*: http://phantomjs.org/download.html

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

## LICENSE

All the sources created are made available under the terms
of the GNU Affero General Public License (GNU AGPLv3).
See the GNU-AGPL-3.0.txt file for more details.
