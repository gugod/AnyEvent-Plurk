# -*- text -*-
use inc::Module::Install::DSL 0.91;

all_from       lib/AnyEvent/Plurk.pm
requires_from  lib/AnyEvent/Plurk.pm

build_requires Test::More 0.88

license        mit
repository     http://github.com/gugod/AnyEvent-Plurk

tests          t/*.t
