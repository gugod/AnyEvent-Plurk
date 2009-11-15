#!/usr/bin/env perl
use common::sense;
use Test::More;

unless($ENV{TEST_ANYEVENT_PLURK}) {
    plan skip_all => "define TEST_ANYEVENT_PLURK env to test.";
}

use AnyEvent::Plurk;

my ($username,$password) = split(" ", $ENV{TEST_ANYEVENT_PLURK});

my $p = AnyEvent::Plurk->new(
    username => $username,
    password => $password
);

$p->reg_cb(
    latest_owner_plurks => sub {
        my ($p, $plurks) = @_;
        pass("Received latest plurks");
        is(ref($plurks), "ARRAY");
    }
);

$p->start;

done_testing;
