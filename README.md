# ManageIQ plugin for the Redfish provider

[![Gem Version](https://badge.fury.io/rb/manageiq-providers-redfish.svg)](http://badge.fury.io/rb/manageiq-providers-redfish)
[![Build Status](https://travis-ci.org/ManageIQ/manageiq-providers-redfish.svg)](https://travis-ci.org/ManageIQ/manageiq-providers-redfish)
[![Code Climate](https://codeclimate.com/github/ManageIQ/manageiq-providers-redfish.svg)](https://codeclimate.com/github/ManageIQ/manageiq-providers-redfish)
[![Test Coverage](https://codeclimate.com/github/ManageIQ/manageiq-providers-redfish/badges/coverage.svg)](https://codeclimate.com/github/ManageIQ/manageiq-providers-redfish/coverage)
[![Dependency Status](https://gemnasium.com/ManageIQ/manageiq-providers-redfish.svg)](https://gemnasium.com/ManageIQ/manageiq-providers-redfish)
[![Security](https://hakiri.io/github/ManageIQ/manageiq-providers-redfish/master.svg)](https://hakiri.io/github/ManageIQ/manageiq-providers-redfish/master)

[![Chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ManageIQ/manageiq-providers-redfish?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Translate](https://img.shields.io/badge/translate-zanata-blue.svg)](https://translate.zanata.org/zanata/project/view/manageiq-providers-redfish)


## Quickstart

Redfish provider is installed by default when seting up ManageIQ development
environment. To start using it, navigate to the `Compute` ->
`Physical Infrastructure` -> `Providers` and add new provider of type Redfish.


## Development environment setup

See the [ManageIQ Developer Setup guide][dev-setup] for help on installing
prerequistes for ManageIQ development. In this section, we will assume that
ManageIQ core repo resides in `~/miq/manageiq`, so adjust path accordingly.

   [dev-setup]: https://manageiq.org/docs/guides/developer_setup
                (ManageIQ developer setup)

Now, to start working on Redfish provider, we must first clone the repo:

    $ cd ~/miq
    $ git clone git@github.com:ManageIQ/manageiq-providers-redfish.git
    $ cd manageiq-providers-redfish

After this is done, we must perform the initial setup by running

    $ bin/setup

After the initial setup is done, we can test the environment by executing

    $ bundle exec rake

This command should run test suite and return with no error. If this is not
the case, congratulations to us, since we can start debugging our setup;) If
everything is green, we are ready start adding ~~bugs~~ features to the
Redfish provider.

To be able to view and test the changes we are making to the provider, we must
override the gem sources in `~/miq/manageiq/bundler.d/overrides.rb`. In our
case, `overrides.rb` should look something like this:

    override_gem "manageiq-providers-redfish",
      :path => File.expand_path("~/miq/manageiq-providers-redfish")

Do not use relative path in `File.expand_path` call, since this is just
calling for troubles. To actually install the local gems, run

    $ ( cd ../manageiq && bin/update )

Now ManageIQ will use the local manageiq-providers-redfish repository instead
of fetching from GitHub. This will allow you to test changes and debug before
your changes have been merged.

But it will not take long for us to get into situation where we will need to
modify some other parts of the ManageIQ in order to get new feature in. In
order to be able to run automated test suite in such situations, we need to
remove `~/miq/manageiq-providers-redfish/spec/manageiq` folder and replace it
with symbolic link to `~/miq/manageiq`. To get things updated, we need to run

    $ bin/update

Last thing we need in order to be able to develop Redfish provider is mock
Redfish server. And fortunately for us, it has been already installed as a
part of an initial setup. We just need to get our hands on some recordings and
we are good to go.

One recording is available in [XLAB's repo][redfish-recordings]. We can clone
it and instruct mock server to serve it:

    $ ( cd ~/miq && git clone https://github.com/xlab-si/redfish-recordings )
    $ bundle exec redfish serve ../redfish-recordings/lenovo-sr650

   [redfish-recordings]: https://github.com/xlab-si/redfish-recordings
                         (XLAB's repo with Redfish recordings)


### Advanced setup (if we need changes in core)

 1. remove `spec/manageiq` and replace it with a symlink to ~/miq/manageiq
 2. checkout proper branch in ~/miq/manageiq
 3. bin/update in ~/miq/manageiq
 4. bundle exec rake

### Testing changes manually

 1. edit ~/miq/manageiq/bundler.d/overrides.rb
 2. bin/update
 3. MIQ_SPARTAN=minimal:ems_inventory bundle exec rake evm:start
 4. go to localhost:3000 (admin/smartvm)


## License

The gem is available as open source under the terms of the
[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git add ...` and `git commit`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
