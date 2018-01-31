package EventSourcing::Tiny::Event;

use strict;
use warnings;
use Mo qw(default required);

use UUID::Tiny qw(create_uuid_as_string);
use Time::HiRes qw(time);

has uuid            => sub {create_uuid_as_string};
has timestamp       => sub {time};
has name            => required => 1;
has transformation  => sub {sub {}};

1;
__END__
