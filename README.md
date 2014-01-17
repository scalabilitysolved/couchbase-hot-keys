couchbase-hot-keys
==================

Ruby script to retreive the hottest (most used keys) from a bucket for a specific timeframe (minute up to a year granularity), can also include additional stats such as doc/view fragmentation.

To run script first you will need to be running ruby on your box.

1. ``` bundle install ```
2. Run script without arguments to see list of flags/options ``` ruby CouchbaseHotKeys.rb ``` or with ``` -h or --help```


Example request:

``` ruby CouchbaseHotKeys.rb --ip '127.0.0.1' --zoom 'week' --bucket 'players' --stats ```