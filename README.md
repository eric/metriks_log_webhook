# Metriks log reporter webhook

Webhook receiver for taking logs from [metriks](https://github.com/eric/metriks/)
and sending them to [Librato Metrics](https://metrics.librato.com) via
a [Papertrail](https://papertrailapp.com/) webhook.


# Setup

## Step 1: Integrate metriks into your project

To get anything useful out of this, you have to already be using
[metriks](https://github.com/eric/metriks/).


## Step 2: Setup the metriks logger reporter

Once you've done that, setup a logger reporter. For example:

``` ruby
  # Setup metriks logger
  require 'metriks/reporter/logger'

  metriks_logger = ActiveSupport::BufferedLogger.new(Rails.root.join('log/metriks.log').to_s)
  metriks_logger.level = Logger::INFO
  Metriks::Reporter::Logger.new(:logger => metriks_logger).start
```

## Step 3: Send the logs to Papertrail

Once you've done that, send the log to [Papertrail](https://papertrailapp.com/).
The easiest way would be to use [remote_syslog](https://github.com/papertrail/remote_syslog/):

    $ remote_syslog -p <your_papertrail_port> /srv/www/app/shared/log/metriks.log


## Step 4: Create an instance of this webhook on heroku

The easiest way to run this is to grab the code and run a copy on heroku:

    $ git clone git@github.com:eric/metriks_log_webhook.git
    $ cd metriks_log_webhook
    $ bundle
    $ heroku create --stack cedar
    $ heroku addons:add memcache
    $ git push heroku master
    $ heroku config:add METRICS_EMAIL=<librato_metrics_email> METRICS_TOKEN=<librato_metrics_token>

## Step 5: Create a saved search in Papertrail

Then create a saved search in Papertrail for:

    "metriks: "


## Step 6: Create a search alert and point it to the webhook

Create a Search Alert in Papertrail to fire every minute pointed at `/submit`.

For instance:

    http://holler-mountain-37.herokuapp.com/submit

Once you've done that, you should start to see metrics in your Librato Metrics
dashboard.


# License

Copyright (c) 2012 Eric Lindvall

Published under the MIT License, see LICENSE
