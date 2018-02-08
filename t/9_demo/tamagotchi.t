use strict;
use warnings;

use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok 'Tamagotchi';

my $tama_sto = Tamagotchi->new;
isa_ok $tama_sto => 'Tamagotchi';
my $user;

subtest 'User handling' => sub {

    # create
    my $anne    = $tama_sto->add_user('Anne');
    my $bob     = $tama_sto->add_user('Bob');
    $user = $bob;

    subtest 'Creation' => sub {

        # check IDs from creation
        is $anne => 0, 'Correct first user ID';
        is $bob  => 1, 'Correct second user ID';

        subtest 'Events' => sub {
            is $tama_sto->_event_store->events->length => 2,
                '2 events recorded';

            # first user
            my $add_anne = $tama_sto->_event_store->events->events->[0];
            isa_ok $add_anne => 'EventStore::Tiny::DataEvent';
            is $add_anne->name => 'UserAdded', 'Correct event type';
            is_deeply $add_anne->data => {
                user_id     => $anne,
                user_name   => 'Anne',
            }, 'Correct event data';

            # second user
            my $add_bob  = $tama_sto->_event_store->events->events->[1];
            isa_ok $add_bob => 'EventStore::Tiny::DataEvent';
            is $add_bob->name => 'UserAdded', 'Correct event type';
            is_deeply $add_bob->data => {
                user_id     => $bob,
                user_name   => 'Bob',
            }, 'Correct event data';
        };

        # check state after creation
        is_deeply $tama_sto->data => {
            users => {
                $anne   => {id => $anne, name => 'Anne'},
                $bob    => {id => $bob, name => 'Bob'},
            },
        }, 'Correct state after user creation';
    };

    # rename
    $tama_sto->rename_user($bob, 'Bill');
    my $bill = $bob;

    subtest 'Renaming' => sub {

        subtest 'Event' => sub {
            is $tama_sto->_event_store->events->length => 3,
                'Three events recorded';

            my $rename = $tama_sto->_event_store->events->events->[2];
            isa_ok $rename => 'EventStore::Tiny::DataEvent';
            is $rename->name => 'UserRenamed', 'Correct event type';
            is_deeply $rename->data => {
                user_id     => $bill,
                user_name   => 'Bill',
            }, 'Correct event data';
        };

        # check state after renaming
        is_deeply $tama_sto->data => {
            users => {
                $anne   => {id => $anne, name => 'Anne'},
                $bill   => {id => $bill, name => 'Bill'},
            },
        }, 'Correct state after user creation';
    };

    # remove
    $tama_sto->remove_user($anne);

    subtest 'Removal' => sub {

        subtest 'Events' => sub {
            is $tama_sto->_event_store->events->length => 4,
                'Four events recorded';

            my $removal = $tama_sto->_event_store->events->events->[3];
            isa_ok $removal => 'EventStore::Tiny::DataEvent';
            is $removal->name => 'UserRemoved', 'Correct event type';
            is_deeply $removal->data => {
                user_id => $anne,
            }, 'Correct event data';
        };

        # check state after removal
        is_deeply $tama_sto->data => {
            users => {
                $bill => {id => $bill, name => 'Bill'},
            },
        }, 'Correct state after user creation';
    };
};

subtest 'Tamagotchi' => sub {

    my $tama = $tama_sto->add_tamagotchi($user);

    subtest 'Creation' => sub {

        # check id from construction
        is $tama => 0, 'Correct first tamagotchi ID';

        subtest 'Events' => sub {
            is $tama_sto->_event_store->events->length => 5,
                '5 events recorded';

            my $add_tama = $tama_sto->_event_store->events->events->[4];
            isa_ok $add_tama => 'EventStore::Tiny::DataEvent';
            is $add_tama->name => 'TamagotchiAdded', 'Correct event type';
            is_deeply $add_tama->data => {
                user_id => $user,
                tama_id => 0,
            }, 'Correct event data';
        };

        # check state after creation
        is_deeply $tama_sto->data => {
            users => {$user => {id => $user, name => 'Bill'}},
            tamas => {$tama => {
                id      => $tama,
                health  => 100,
                user_id => $user,
            }},
        }, 'Correct state after tamagotchi creation';
    };

    # feed (+0), age (-30), feed (+20)
    $tama_sto->feed_tamagotchi($tama);
    $tama_sto->age_tamagotchi($tama);
    $tama_sto->feed_tamagotchi($tama);

    subtest 'Life' => sub {

        subtest 'Events' => sub {
            is $tama_sto->_event_store->events->length => 8,
                '8 events recorded';

            my ($feed1, $age, $feed2) = @{$tama_sto->_event_store
                ->events->events}[5, 6, 7];
            isa_ok $_ => 'EventStore::Tiny::DataEvent'
                for $feed1, $age, $feed2;
            is_deeply $_->data => {tama_id => $tama}, 'Correct event data'
                for $feed1, $age, $feed2;

            is $feed1->name => 'TamagotchiFed', 'Correct event type';
            is $age->name => 'TamagotchiDayPassed', 'Correct event type';
            is $feed2->name => 'TamagotchiFed', 'Correct event type';
        };

        # check state after daily routine
        is_deeply $tama_sto->data => {
            users => {$user => {id => $user, name => 'Bill'}},
            tamas => {$tama => {
                id      => $tama,
                health  => 90,
                user_id => $user,
            }},
        }, 'Correct state after tamagotchi daily routine';
    };

    subtest 'Death' => sub {
        ok 1 => 'Dummy test'; # TODO
    };
};

done_testing;
