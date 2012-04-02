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
    
    subtest 'number of columns and scalars' => sub {
        my $md = MiscData->new();
        is(6, @{$md->getColumnNames()}, "number of columns");
        is(3, @{$md->getScalarNames()}, "number of scalars");
    };

    subtest 'get columns' => sub {
        try {
            my $md = MiscData->new(&Database::getDBConnection());
            for my $columnName (@{$md->getColumnNames()}) {
                try {
                    my $data = $md->getColumn($columnName);
                    # 2 is a magic, arbitrary number ...
                    ok(scalar(@$data) > 2, "found values for column <$columnName>");
                } catch {
                    ERROR($_);
                    fail($_);
                };
            }
        } catch {
            fail("failed: $_");
        };
    };
    
    subtest 'get scalars' => sub {
        try {
            my $md = MiscData->new(&Database::getDBConnection());
            for my $scalarName (@{$md->getScalarNames()}) {
                try {
                    my $data = $md->getScalar($scalarName);
                    ok($data, "found values for scalar <$scalarName>");
                } catch {
                    ERROR($_);
                    fail($_);
                };
            }
        } catch {
            fail("failed: $_");
        };
    };
    
}

1;