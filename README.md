# ManageIQ::Providers::Redfish

[![CI](https://github.com/ManageIQ/manageiq-providers-redfish/actions/workflows/ci.yaml/badge.svg?branch=spassky)](https://github.com/ManageIQ/manageiq-providers-redfish/actions/workflows/ci.yaml)
[![Maintainability](https://api.codeclimate.com/v1/badges/80ba546f5ac1d1fd09fc/maintainability)](https://codeclimate.com/github/ManageIQ/manageiq-providers-redfish/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/80ba546f5ac1d1fd09fc/test_coverage)](https://codeclimate.com/github/ManageIQ/manageiq-providers-redfish/test_coverage)

[![Chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ManageIQ/manageiq-providers-redfish?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build history for spassky branch](https://buildstats.info/github/chart/ManageIQ/manageiq-providers-redfish?branch=spassky&buildCount=50&includeBuildsFromPullRequest=false&showstats=false)](https://github.com/ManageIQ/manageiq-providers-redfish/actions?query=branch%3Amaster)

ManageIQ plugin for the Redfish provider.

## Quickstart

Redfish provider is installed by default when setting up ManageIQ development
environment. To start using it, navigate to the `Compute` ->
`Physical Infrastructure` -> `Providers` and add new provider of type Redfish.

## Development

See the section on plugins in the [ManageIQ Developer Setup](http://manageiq.org/docs/guides/developer_setup/plugins)

For quick local setup run `bin/setup`, which will clone the core ManageIQ repository under the *spec* directory and setup necessary config files. If you have already cloned it, you can run `bin/update` to bring the core ManageIQ code up to date.

### Mock Server

A useful tool to be able to develop the Redfish provider is the mock
Redfish server. And fortunately for us, it has been already installed as a
part of an initial setup. We just need to get our hands on some recordings and
we are good to go.

One recording is available in [XLAB's repo][redfish-recordings]. We can clone
it and instruct mock server to serve it:

    $ ( cd ~/miq && git clone https://github.com/xlab-si/redfish-recordings )
    $ bundle exec redfish serve ../redfish-recordings/lenovo-sr650

   [redfish-recordings]: https://github.com/xlab-si/redfish-recordings
                         (XLAB's repo with Redfish recordings)

## License

The gem is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
