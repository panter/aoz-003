# AOZ Voluntary Platform

## Pipeline Status

- Develop: [![pipeline status](https://git.panter.ch/open-source/aoz-003/badges/develop/pipeline.svg)](https://git.panter.ch/open-source/aoz-003/commits/develop) | [![coverage report](https://git.panter.ch/open-source/aoz-003/badges/develop/coverage.svg)](https://git.panter.ch/open-source/aoz-003/-/commits/develop)
- Main: [![pipeline status](https://git.panter.ch/open-source/aoz-003/badges/main/pipeline.svg)](https://git.panter.ch/open-source/aoz-003/commits/main) | [![coverage report](https://git.panter.ch/open-source/aoz-003/badges/main/coverage.svg)](https://git.panter.ch/open-source/aoz-003/-/commits/main)


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
    * [Configuration Env variables](#configuration-env-variables)
      * [Production relevant](#production-relevant)
        * [Mailgun Configuration](#mailgun-configuration)
        * [Email address config](#email-address-config)
        * [Google S3 storage bucket config for active storage](#google-s3-storage-bucket-config-for-active-storage)
        * [Sftp configuration for coplaner excel upload job](#sftp-configuration-for-coplaner-excel-upload-job)
      * [Auxiliary and less important](#auxiliary-and-less-important)
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

### Configuration Env variables

#### Production relevant

##### Mailgun Configuration

- MAILGUN_SMTP_PORT
- MAILGUN_SMTP_SERVER
- MAILGUN_SMTP_LOGIN
- MAILGUN_SMTP_PASSWORD
- MAILGUN_DOMAIN

##### Email address config

The Mail links domain base created for invite or password reset links in emails sent out.

- DEVISE_EMAIL_DOMAIN
- DEVISE_EMAIL_PROTOCOL

##### Google S3 storage bucket config for active storage

- GOOGLE_PROJECT_ID
- GOOGLE_PRIVATE_KEY_ID
- GOOGLE_PRIVATE_KEY
- GOOGLE_CLIENT_EMAIL
- GOOGLE_CLIENT_ID
- GOOGLE_CLIENT_X509_CERT_URL
- GOOGLE_PROJECT_ID
- GOOGLE_BUCKET

##### Sftp configuration for coplaner excel upload job

- SFTP_HOST
- SFTP_USER
- SFTP_PASS

#### Auxiliary and less important

- TEST_TYPE - For CI pipeline writing different coverage reports for minitest and capybara tests
- driver - if set and its value is "visible" chrome will not run headless for system tests
- RUN_DEV_SEED_IN_PRODUCTION_ENV - if "1" it still runs the development seed, even if the Rails env is production

### LICENSE

All the sources created are made available under the terms
of the GNU Affero General Public License (GNU AGPLv3).
See the GNU-AGPL-3.0.txt file for more details.
