# fluent-plugin-in_forward_ex

[![Build Status](https://secure.travis-ci.org/sonots/fluent-plugin-in_forward_ex.png?branch=master)](http://travis-ci.org/sonots/fluent-plugin-in_forward_ex)

Yet another extension of Fluentd in_forward plugin

## Parameters

Following parameters are additionally available. See also [original options](http://docs.fluentd.org/articles/in_forward) on in_forward.

- stop_file FILE

    Stop receiving new data if specified file exists

- stop_file_interval TIME

    Chech `stop_file` every specified seconds (default: 5)

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2015 Naotoshi Seo. See [LICENSE](LICENSE) for details.

