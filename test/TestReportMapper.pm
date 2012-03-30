use strict;
use warnings;

package TestReportMapper;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use ReportMapper;

use lib '../src/database';
use Database;


sub runTests {
  
    subtest 'get available reports' => sub {
        my $mapper = ReportMapper->new(); # &Database::getDBConnection());
        my $reps = $mapper->getAvailableReports();
        my $len = scalar(@$reps);
        is($len, 12, "number of available reports: <$len>");
    };    
    
    subtest 'retrieve reports from database' => sub {
        try {   
            my $mapper = ReportMapper->new(&Database::getDBConnection());
            my $reports = $mapper->getAvailableReports();
            for my $report (@$reports) {
                my $len = 0;
                try {
                    my ($report) = $mapper->getReport($report);
                    $len = scalar(@{$report->getHeadings()});
                } catch {
                    ERROR("error accessing report: $_");
                };
                ok($len > 0, "report <$report>");
            }
        } catch {
            ERROR($_);
            fail($_);
        };
    };
}

1;