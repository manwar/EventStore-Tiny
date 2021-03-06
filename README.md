[![CPAN version](https://badge.fury.io/pl/EventStore-Tiny.svg)](https://badge.fury.io/pl/EventStore-Tiny)
[![Travis CI tests](https://travis-ci.org/memowe/EventStore-Tiny.svg?branch=master)](https://travis-ci.org/memowe/EventStore-Tiny)
[![Codecov test coverage](https://codecov.io/gh/memowe/EventStore-Tiny/branch/master/graph/badge.svg)](https://codecov.io/gh/memowe/EventStore-Tiny)
[![Coveralls test coverage](https://coveralls.io/repos/github/memowe/EventStore-Tiny/badge.svg?branch=master)](https://coveralls.io/github/memowe/EventStore-Tiny?branch=master)
[![CPANTS kwalitee score](https://cpants.cpanauthors.org/dist/EventStore-Tiny.png)](http://cpants.cpanauthors.org/dist/EventStore-Tiny)
<br>
[![CPAN testers reports](https://img.shields.io/badge/testers-reports-blue.svg)](http://www.cpantesters.org/distro/E/EventStore-Tiny.html?distmat=1)
[![CPAN testers matrix](https://img.shields.io/badge/testers-matrix-blue.svg)](http://matrix.cpantesters.org/?dist=EventStore-Tiny)
[![GitHub repository](https://img.shields.io/badge/github-code-blue.svg)](https://github.com/memowe/EventStore-Tiny)
[![GitHub issue tracker](https://img.shields.io/badge/github-issues-blue.svg)](https://github.com/memowe/EventStore-Tiny/issues)

# EventStore::Tiny

A minimal event sourcing framework.

## Example

```perl
use EventStore::Tiny;

my $store = EventStore::Tiny->new;

# Register event type
$store->register_event(UserAdded => sub {
    my ($state, $data) = @_;

    # Use $data to inject the new user into the given $state
    $state->{users}{$data->{id}} = {
        name => $data->{name},
    };
});

# ...

# Store an event instance represented by type and data
$store->store_event(UserAdded => {id => 17, name => 'Bob'});

# ...

# Work with the current state snapshot generated by event application
say 'His name is ' . $store->snapshot->state->{users}{17}{name}; # Bob
```

## Intro

In Event Sourcing, the state of a system is calculated as the application of a stream of events representing each change of the system. This framework is a minimal approach to use these mechanics in simple perl systems.

## Features

- Flexible snapshots (high-resolution timestamps) and event substreams
- Customizable event logging
- Simple storage solution for events in the file system
- Transparent snapshot caching mechanism to improve performance

## Read more

- See the module's POD ([EventStore::Tiny on MetaCPAN][mcpan]) for details.
- See [Tamagotchi.pm][tpm] and [tamagotchi.t][tt] for a non-trivial demo.

[mcpan]: https://metacpan.org/pod/EventStore::Tiny
[tpm]: t/9_demo/lib/Tamagotchi.pm
[tt]: t/9_demo/tamagotchi.t

## Author and license

Copyright (c) 2018 [Mirko Westermeier][mw] ([\@memowe][gh], [mirko@westermeier.de][mail])

Released under the MIT License (see [LICENSE.txt][license]).

### Contributors

- Mohammad S Anwar ([\@manwar][manwar])
- Toby Inkster ([\@tobyink][tobyink])

[mw]: http://mirko.westermeier.de
[gh]: https://github.com/memowe
[mail]: mailto:mirko@westermeier.de
[license]: LICENSE.txt
[manwar]: https://github.com/manwar
[tobyink]: https://github.com/tobyink
