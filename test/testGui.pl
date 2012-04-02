use strict;
use warnings;

use Test::More;
use Try::Tiny;

use Log::Log4perl qw(:easy);
BEGIN {
    Log::Log4perl->easy_init({
        level   => $DEBUG,
        file    => ">testGui.txt",
        layout  => '%p  %F{1}-%L-%M: (%d) %m%n' 
    });
}


use TestGui;


&TestGui::runTests();

&done_testing();
