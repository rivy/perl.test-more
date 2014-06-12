use strict;
use warnings;
use Test::More;
use Test::Builder::Stream::Tester;
use Test::Builder::Result::Ok;

my $CLASS = 'Test::Builder::Fork';
require_ok $CLASS;

my $one = $CLASS->new;
isa_ok($one, $CLASS);
ok($one->tmpdir, "Got temp dir");

my $handler = $one->handler;
is(ref $handler, 'CODE', "Handler is a coderef");

my $TB = Test::Builder->new;

my $Ok = Test::Builder::Result::Ok->new(
    context   => {fake => 1},
    bool      => 1,
    real_bool => 1,
    name      => 'fake',
    number    => 1,
);

my $out = $handler->($TB, $Ok);
ok(!$out, "Did not snatch result in parent process");

if (my $pid = fork()) {
    waitpid($pid, 0);
}
else {
    $handler->($TB, $Ok);
    exit 0;
}

my $results = intercept { $one->cull($TB) };

is_deeply(
    $results,
    [$Ok],
    "got result after cull"
);

done_testing;
