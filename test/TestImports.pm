use strict;
use warnings;

package TestImports;

use Test::More;
use lib '../src/gui';
use lib '../src/model';


sub runTests {

    BEGIN { use_ok('AddTransaction'); }
    BEGIN { use_ok('Balances'); }
    BEGIN { use_ok('CheckBox'); }
    BEGIN { use_ok('ComboBox'); }
    BEGIN { use_ok('EditTransaction'); }
    BEGIN { use_ok('BaseTransaction'); }
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
    
    BEGIN { use_ok('Balance'); }
    BEGIN { use_ok('Messages'); }
    BEGIN { use_ok('MiscData'); }
    BEGIN { use_ok('Report'); }
    BEGIN { use_ok('Service'); }
    BEGIN { use_ok('Transaction'); }

};

1;