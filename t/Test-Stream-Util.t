use strict;
use warnings;

use Test::More 'modern';

use ok 'Test::Stream::Util', qw{
    try protect is_regex is_dualvar
};

can_ok(__PACKAGE__, qw{
    try protect is_regex is_dualvar
});

# $! is a dualvar.
$! = 100;
my $x = $!;
ok(is_dualvar($x), "Got dual var");
$x = 1;
ok(!is_dualvar($x), "Not dual var");

$! = 100;

my $ok = eval { protect { die "xxx" }; 1 };
ok(!$ok, "protect did not capture exception");
like($@, qr/xxx/, "expected exception");

cmp_ok($!, '==', 100, "\$! did not change");
$@ = 'foo';

($ok, my $err) = try { die "xxx" };
ok(!$ok, "cought exception");
like( $err, qr/xxx/, "expected exception"); 
is($@, 'foo', '$@ is saved');
cmp_ok($!, '==', 100, "\$! did not change");

ok(is_regex(qr/foo bar baz/), 'qr regex');
ok(is_regex('/xxx/'), 'slash regex');
ok(!is_regex('xxx'), 'not a regex');

done_testing;
