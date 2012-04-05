use strict;
use warnings;

package TestDate;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Date;



sub runTests {

    subtest 'create valid dates' => sub {
        try {
            my $d1 = Date->new(2012, 8, 0);
            pass("created date 1");
            
            my $d2 = Date->new(2010, 4, 22);
            pass("created date 2");
        } catch {
            ERROR($_);
            fail($_);
        };
    };
    
    subtest 'test parse y-m-d' => sub {
        try {
            my $d1 = Date->fromYMD('1994-01-08');
            ok(8 == $d1->{day});
            ok(1 == $d1->{month});
            ok(1994 == $d1->{year});
            
            my $d2 = Date->fromYMD('2008-12-23');
            ok(12 == $d2->{month}, "second month: got $d2->{month}, expected 12");
        } catch {
            ERROR($_);
            fail($_);
        };
    };
    
    subtest 'test format y-m-d' => sub {
        try {
            my $d1 = Date->new('2004', '4', 6);
            is('2004-4-6', $d1->toYMD());
        } catch {
            ERROR($_);
            fail($_);
        };
    };
    
    subtest 'create invalid dates' => sub {
        try {
            my $d1 = Date->new(2012, 8);
            fail("missing day");
        } catch {
            pass($_);
        };
        
        try {
            my $d1 = Date->new();
            fail("missing all fields");
        } catch {
            pass($_);
        };
        
        try {
            my $d1 = Date->new(2012, 8, 32);
            fail("bad day");
        } catch {
            pass($_);
        };
        
        try {
            my $d1 = Date->new(2012, 18, 21);
            fail("bad month");
        } catch {
            pass($_);
        };
    };
    
}

1;