use strict;
use warnings;

package TestMiscData;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use MiscData;

use lib '../src/database';
use Database;


sub runTests {

    subtest 'get columns' => sub {
        try {
            &MiscData::setDbh(&Database::getDBConnection());
            for my $columnName (&MiscData::getColumnNames()) {
                try {
                    my $data = &MiscData::getColumn($columnName);
                    ok(scalar(@$data) > 2, "found values for column <$columnName>");
                } catch {
                    fail("failed to obtain values for column <$columnName>");
                };
            }
        } catch {
            fail("failed: $_");
        };
    };
    
    subtest 'get scalars' => sub {
        try {
            &MiscData::setDbh(&Database::getDBConnection());
            for my $scalarName (&MiscData::getScalarNames()) {
                try {
                    my $data = &MiscData::getScalar($scalarName);
                    ok($data, "found values for scalar <$scalarName>");
                } catch {
                    fail("failed to obtain value for scalar <$scalarName>");
                };
            }
        } catch {
            fail("failed: $_");
        };
    };
    
}

1;