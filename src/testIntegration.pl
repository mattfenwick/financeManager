
use strict;
use warnings;
use Test::More;


BEGIN { use_ok('AddTransaction'); }
BEGIN { use_ok('Balances'); }
BEGIN { use_ok('ComboBox'); }
BEGIN { use_ok('Controller'); }
BEGIN { use_ok('EditTransaction'); }
BEGIN { use_ok('FinanceGUI'); }
BEGIN { use_ok('LabelEntry'); }
BEGIN { use_ok('Reports'); }
BEGIN { use_ok('ResultViewer'); }
BEGIN { use_ok('WidgetBase'); }
BEGIN { use_ok('Tkx'); }
BEGIN { use_ok('Log::Log4perl'); }
BEGIN { use_ok('parent'); }
BEGIN { use_ok('DBI'); }
BEGIN { use_ok('DBD::mysql'); }

subtest 'Available reports' => sub {
    use Controller;
    
    my $controller = Controller->new();
    my @reports = @{$controller->getAvailableReports()};
    for my $report (@reports) {
        my $len;
        eval {
            my ($headings, $rows) = $controller->getReport({query => $report});
            $len = scalar(@$headings);
        } || ($len = 0);
        ok($len > 0, "report <$report>");
    }
};

done_testing();