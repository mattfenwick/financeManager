use strict;
use warnings;

package TestReport;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Report;


sub runTests {
    
    subtest 'bad reports trip up validation' => sub {
        my $tooManyCols = 1;
        my $missingKey = 1;
        try {
            Report->new(["abc", "def"], [[1, 2, 3]]);
            $tooManyCols = 0;
        } catch {
            ok($tooManyCols, "too many columns correctly caused exception");
        };
        try {
            Report->new(["abc", "def"], [[11,21], [14], ['hi', 'bye']]);
            $missingKey = 0;
        } catch {
            ok($missingKey, "missing key correctly caused exception");
        };
    };
    
    subtest 'getters: headings and rows' => sub {
        my $rep = Report->new(["abc", "123"], [
            [13, 'hello'], 
            ['what?', 'woof'], 
            [34, 13]
        ]);
        is(2, scalar(@{$rep->getHeadings()}), "number of columns");
        is(3, scalar(@{$rep->getRows()}),     "number of rows");
        is("ARRAY", ref($rep->getHeadings()), "type of getHeadings");
        is("ARRAY", ref($rep->getRows()),     "type of getRows");
        is("ARRAY", ref($rep->getRows()->[0]),     "type of first row");
    };

}

1;