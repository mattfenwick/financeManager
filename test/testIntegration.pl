
use strict;
use warnings;
use Test::More;
use lib '../src';
use lib '../src/gui';
#BEGIN {
#	push(@INC, '../src');
#	push(@INC, '../src/gui');
#}; # is there a better way to get this file to see the other files?

BEGIN { use_ok('AddTransaction'); }
BEGIN { use_ok('Balances'); }
BEGIN { use_ok('ComboBox'); }
BEGIN { use_ok('Model'); }
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
    use Model;
    
    my $model = Model->new();
    my @reports = @{$model->getAvailableReports()};
    for my $report (@reports) {
        my $len;
        eval {
            my ($headings, $rows) = $model->getReport({query => $report});
            $len = scalar(@$headings);
        } || ($len = 0);
        ok($len > 0, "report <$report>");
    }
};

done_testing();