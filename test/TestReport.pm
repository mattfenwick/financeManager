use strict;
use warnings;

use Test::More;
use Try::Tiny;

use lib '../src/model';
use Report;


subtest 'Model Reports' => sub {
    
    subtest 'get available reports' => sub {
        my $reps = &Report::getAvailableReports();
        my $len = scalar(@$reps);
        is($len, 12, "number of available reports: <$len>");
    };
    
    subtest 'bad reports trip up validation' => sub {
    	my $tooManyCols = 1;
    	my $missingKey = 1;
        try {
            Report->new(["abc", "def"], [{"abc"=> 1, "def"=> 2, "ghi"=> 3}]);
            $tooManyCols = 0;
        } catch {
            ok($tooManyCols, "too many columns correctly caused exception");
        };
        try {
            Report->new(["abc", "def"], [{"abc"=> 11, "def" => 21}, {"def"=> 14}, {"abc" => 'hi', "def" => "bye"}]);
            $missingKey = 0;
        } catch {
            ok($missingKey, "missing key correctly caused exception");
        };
    };
    
    subtest 'getters: headings and rows' => sub {
        my $rep = Report->new(["abc", "123"], [
            {"abc"=> 13, "123"=> 'hello'}, 
            {"123" => 'what?', 'abc' => 'woof'}, 
            {"123"=> 34, "abc" => 13}
        ]);
        is(2, scalar(@{$rep->getHeadings()}), "number of columns");
        is(3, scalar(@{$rep->getRows()}),     "number of rows");
        is("ARRAY", ref($rep->getHeadings()), "type of getHeadings");
        is("ARRAY", ref($rep->getRows()),     "type of getRows");
    };
    
    subtest 'retrieve reports from database' => sub {
        use Service;
        
        my @reports = @{&Service::getAvailableReports()};
        for my $report (@reports) {
            my $len = 0;
            try {
                my ($report) = &Service::getReport($report);
                $len = scalar(@{$report->{headings}});
            }
            ok($len > 0, "report <$report>");
        }
    };
};

1;