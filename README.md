# Judy

## Screenshots

### Listing Abstracts

![list](https://github.com/obfuscurity/judy/raw/master/screenshots/03_abstracts.png "List of Abstracts")

### Reading and Scoring an Abstract

![score](https://github.com/obfuscurity/judy/raw/master/screenshots/04_review.png "Reviewing an Abstract")

### Reviewing Scores

![review](https://github.com/obfuscurity/judy/raw/master/screenshots/05_results-mean.png "Scoring Results")

## Purpose

A small Sinatra app for reading and voting on event CFP submissions. Developed for use with the Monitorama conferences.

## Goals

The traditional for reviewing and sorting through conference CFP submissions is a tedious and thankless task. Most conference organizers recognize this as a largely manual effort, using some combination of spreadsheets and dead trees. Judy aims to streamline the process, with the ultimate goal of having the abstract review process as enjoyable as reading stories on Instapaper within your favorite tablet device.

Judy's design goals are straightforward:

* Collecting abstracts should be easy.
* Reading abstracts should be enjoyable.
* Interpreting the results should be simple.
* The interface should fulfill all of the above requirements, particularly on mobile devices, with as few clicks as possible.

Judy has already helped us to review seventy-eight (78) submissions for the upcoming Monitorama PDX conference in record time. It enabled us to bring in a larger team of volunteers to review and judge papers than would have previously been possible, increasing diversity and helping to float the very best talks to the top of the stack.

## Deployment

Judy stores all of its relational data in PostgreSQL. It is assumed you have a local PostgreSQL server available for development.

### Options

All environment variables can be set from the command-line, although it's suggested to use `.env` instead. This file will automatically be picked up by foreman, which is also helpful when debugging (e.g. `foreman run pry`). This file will not be committed (unless you remove or modify `.gitignore`) so you shouldn't have to worry about accidentally leaking credentials.

* `DATABASE_URL` (required)
* `JUDY_AUTH` (required)
* `JUDY_ADMIN` (optional)
* `FORCE_HTTPS` (optional)

### Authorization

The Judy UI is protected by Basic Authentication. Credentials should be set using the `JUDY_AUTH` environment variable as colon-delimited credential pairs. Multiple pairs should be delimited with commas. For example:

```
JUDY_AUTH=user1:foo,user2:bar,user3:baz
```

Users with administrative privileges should have their username(s) added to the `JUDY_ADMIN` environment variable. From the previous example, if user1 and user3 are allowed to edit abstracts, your variable should look like this:

```
JUDY_ADMIN=user1,user3
```

Administrators are able to *edit* and *delete* abstracts from the abstract view.

### Local

Judy uses the Sinatra web framework under Ruby 1.9. Anyone wishing to run Judy as a local service should be familiar with common Ruby packaging and dependency management utilities such as RVM and Bundler. If you are installing a new Ruby version with RVM, make sure that you have the appropriate OpenSSL development libraries installed before compiling Ruby.

```bash
$ rvm use 1.9.3
$ bundle install
$ createdb judy
$ cp .env.example .env
$ $EDITOR .env
$ export DATABASE_URL=... # needed for rake task
$ bundle exec rake db:migrate:up
$ foreman start
$ open http://127.0.0.1:5000
```

### Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Or, to deploy manually:

```bash
$ heroku create
$ git push heroku master
$ heroku run bundle exec rake db:migrate:up
$ heroku config:set JUDY_AUTH=user:pass
$ heroku config:set FORCE_HTTPS=true
$ heroku open
```

### Migrations

Database upgrades (or downgrades) should use the built-in `rake` migration targets. For upgrading to the newest version in your development or non-Heroku production environment:

```bash
$ bundle exec rake db:migrate:up
```

If for some reason you need to downgrade to a previous migration target, make sure to set the `VERSION` number:

```bash
$ bundle exec VERSION=3 rake db:migrate:to
```

If you're running on Heroku, simply prefix the aforementioned commands with `heroku run` (and any other relevant options).

## License

Judy is distributed under the MIT license. Third-party software libraries included with this project are distributed under their respective licenses.
