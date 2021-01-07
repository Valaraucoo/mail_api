## Simple Erlang Mailing API

### Getting started

This application was written as a final project in the subject of concurrent programming at AGH UST.

The purpose of this application is to maintain a simple database of users' email addresses and to send email messages to all added users via the Gmail SMTP service.

Application is built on top of the Erlang [Cowboy](https://ninenines.eu/docs/en/cowboy/2.8/guide/) web server, which exposes simple Create, Retrieve, Update and Delete operations using HTTP.

Cowboy provides a complete HTTP stack for creating REST APIs, while the [`gen_smtp`](https://github.com/gen-smtp/gen_smtp) library allows connection to the smtp server (ex. [Google Gmail SMTP](https://support.google.com/a/answer/2956491?hl=pl)).

### Setting up Gmail for external applications

We need to make some changes in your Gmail account to send an Email. Visit [this](https://myaccount.google.com/u/4/security?pli=1) link with your account signed in.
Since our web application is not a google registered service, it is a less secured app. Therefore, we allow less secured apps to our settings.
Then scroll down to `Less secure app access` section of the page and turn on the access.


### Requirements & build

* Unix OS (tested on Ubuntu 20.04 and OS X Catalina)
* Erlang/OTP - you can find more details [here](https://www.erlang.org/)

Before starting application you must create [`dets`](https://erlang.org/doc/man/dets.html) database using `db/create_db.escript` bin script:
```
chmod +x db/create_db.escript && ./db/create_db.escript db
```

After that you must add paths to db files in `config/sys.config` file. Moreover, to use the Gmail SMTP service, you must provide a password and login to your account. You can find more details [here](https://support.google.com/accounts/answer/6010255?hl=en).

Note that all the environment variables used in the project are contained in the `config/sys.config` file.

Then, build and start application, using:
```
$ make run
```

After that, you can visit `http://localhost:8080/` on your web browser, or send request to server using `curl`:

```
$ curl http://localhost:8080/
```

### API Specification

* `/api/info` - returns basic info about application and documentation.
* `/api` - accepts only GET requests, returns all user's emails in the database:
  ```
  $ curl -X GET http://localhost:8080/api
  ```
  You can also browse user's emails using `GET` query parameter:
  ```
  $ curl -X GET http://localhost:8080/api?email=kamil
  ```
  Such query will return all email addresses containing the phrase `kamil`.
* `/api/create` - accepts only POST requests with valid email data which will be added to database:
  ```
  $ curl -X POST -d 'user@host.test' http://localhost:8080/api/create
  ```
* `/api/get/:id` - accepts only GET requests, retrieves single record from database if its exists:
  ```
  $ curl -X GET http://localhost:8080/api/get/:id
  ```
* `/api/update/:id` - accepts only POST requests, updates single record in database if its exists:
  ```
  $ curl -X POST -d 'newuser@host.test' http://localhost:8080/api/update/:id
  ```
* `/api/delete/:id` - accepts only POST requests, delete single record from database if its exists:
  ```
  $ curl -X POST http://localhost:8080/api/delete/:id
  ```
* `/api/send` - accepts only empty POST requests and sends emails to all user's in the database:
  ```
  $ curl -X POST http://localhost:8080/api/send
  ```


### Troubleshooting and errors

* In case the port `8080` is already in use, the application will not start correctly and the process using this port should be killed.

* In case of errors with application dependencies, try comment/uncomment the `DEPS = gen_smtp` line from the `Makefile` file. This error is related to `erlang.mk` problems with multiple dependencies.
