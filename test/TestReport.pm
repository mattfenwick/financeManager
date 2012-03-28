use strict;
use warnings;

package TestReport;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Report;

use lib '../src/database';
use Database;


sub runTests {
    &Report::setDbh(&Database::getDBConnection());
  
    subtest 'get available reports' => sub {
        my $reps = &Report::getAvailableReports();
        my $len = scalar(@$reps);
        is($len, 12, "number of available reports: <$len>");
    };
    
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
    
    subtest 'retrieve reports from database' => sub {        
        my @reports = @{&Report::getAvailableReports()};
        for my $report (@reports) {
            my $len = 0;
            try {
                my ($report) = &Report::getReport($report);
                $len = scalar(@{$report->getHeadings()});
            } catch {
                ERROR("error accessing report: $_");
            };
            ok($len > 0, "report <$report>");
        }
    };

}

1;