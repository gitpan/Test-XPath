#!/usr/bin/perl -w

use strict;
use Test::Builder::Tester;
use Test::More;
use File::Spec;

BEGIN {
    eval 'require HTML::Selector::XPath';
    plan skip_all => 'Install HTML::Selector::XPath to use CSS selectors'
        if $@;
    plan tests => 16;
}

BEGIN { use_ok 'Test::XPath' or die; }

my $html = '<html><head><title>Hello</title><body><p class="foo"><em><b>first</b></em></p><p><em><b>post</b></em></p></body></html>';

ok my $xp = Test::XPath->new(
    xml        => $html,
    is_html    => 1,
    filter     => 'css_selector',
), 'Create Test::XPath object with CSS selector support';

# Try successful ok.
test_out( 'ok 1 - whatever');
$xp->ok('> html > head > title', 'whatever');
test_test('ok works');

# Try failed ok.
my $file = File::Spec->catfile(split m{/} => __FILE__);
test_out('not ok 1 - whatever');
test_err(qq{#   Failed test 'whatever'\n#   at $file line 34.});
$xp->ok('> html > head > foo', 'whatever');
test_test('ok fail works');

# Try a recursive call.
test_out( 'ok 1 - p');
test_out( 'ok 2 - em');
test_out( 'ok 3 - b');
test_out( 'ok 4 - em');
test_out( 'ok 5 - b');

$xp->ok( '> html > body > p', sub {
    shift->ok('> em', sub {
        $_->ok('> b', 'b');
    }, 'em');
}, 'p');
test_test('recursive ok should work');


# Try is, like, and cmp_ok.
$xp->is( ' > html > head > title', 'Hello', 'is should work');
$xp->isnt( ' > html > head > title', 'Bye', 'isnt should work');
$xp->like( ' > html > head > title', qr{^Hel{2}o$}, 'like should work');
$xp->unlike( ' > html > head > title', qr{^Bye$}, 'unlike should work');
$xp->cmp_ok(' > html > head > title', 'eq', 'Hello', 'cmp_ok should work');

# Make them fail.
test_out('not ok 1 - is should work');
test_out('not ok 2 - isnt should work');
test_out('not ok 3 - like should work');
test_out('not ok 4 - unlike should work');
test_out('not ok 5 - cmp_ok should work');
$xp->is( ' > html > head > title', 'Bye', 'is should work');
$xp->isnt( ' > html > head > title', 'Hello', 'isnt should work');
$xp->like( ' > html > head > title', qr{^Bye$}, 'like should work');
$xp->unlike( ' > html > head > title', qr{^Hel{2}o$}, 'unlike should work');
$xp->cmp_ok(' > html > head > title', 'ne', 'Hello', 'cmp_ok should work');
test_test(
    skip_err => 1,
    title => 'Failures in the simple methods should work',
);

# Try multiples.
$xp->is(' > html > body > p', 'firstpost', 'Should work for multiples');

# Try an attribute.
$xp->ok(' > html > body > p[class="foo"]', 'Should find by attribute value');

# Try a non-existent node.
test_out('not ok 1');
$xp->ok(' > foo > baz');
test_test(
    skip_err => 1,
    title => 'Nonexistent node should be false in ok()',
);

# Try successful ok.
test_out( 'ok 1 - whatever');
$xp->not_ok(' > html > head > foo', 'whatever');
test_test('not_ok works');

# Try failed ok.
test_out('not ok 1 - whatever');
test_err(qq{#   Failed test 'whatever'\n#   at $file line 97.});
$xp->not_ok(' > html > head > title', 'whatever');
test_test('not_ok fail works');
