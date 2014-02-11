# Judy

![review](https://github.com/obfuscurity/judy/raw/master/screenshots/03_abstracts.png "Reviewing an Abstract")
![review](https://github.com/obfuscurity/judy/raw/master/screenshots/04_review.png "Reviewing an Abstract")

## Purpose

A small Sinatra app for reading and voting on event CFP submissions. Developed for use with the Monitorama conferences.

## Deployment

Judy stores all of its relational data in PostgreSQl. It is assumed you have a local PostgreSQL server available for development.

### Options

All environment variables can be set from the command-line, although it's suggested to use `.env` instead. This file will automatically be picked up by foreman, which is also helpful when debugging (e.g. `foreman run pry`). This file will not be committed (unless you remove or modify `.gitignore`) so you shouldn't have to worry about accidentally leaking credentials.

* `DATABASE_URL` (required)
* `JUDY_AUTH` (optional)
* `FORCE_HTTPS` (optional)

### Authorization

The Judy UI is protected by Basic Authentication. Credentials should be set using the `JUDY_AUTH` environment variable as colon-delimited credential pairs. Multiple pairs should be delimited with commas. For example:

```
JUDY_AUTH=user1:foo,user2:bar,user3:baz
```

### Local

Judy uses the Sinatra web framework under Ruby 1.9. Anyone wishing to run Judy as a local service should be familiar with common Ruby packaging and dependency management utilities such as RVM and Bundler. If you are installing a new Ruby version with RVM, make sure that you have the appropriate OpenSSL development libraries installed before compiling Ruby.

```bash
$ rvm use 1.9.3
$ bundle install
$ createdb judy
$ cp .env.example .env
$ $EDITOR .env
$ bundle exec rake db:migrate:up
$ foreman start
$ open http://127.0.0.1:5000
```

### Heroku

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
