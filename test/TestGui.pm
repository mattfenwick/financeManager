use strict;
use warnings;

package TestGui;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use MockService;

use lib '../src/gui';
use FinanceGUI;


sub runTests {
    
    subtest 'start and stop gui' => sub {
        try {
            my $service = MockService->new();
            my $gui = FinanceGUI->new($service);
    
            pass("gui started without exceptions");
            
            $gui->viewReports();
            
            pass("started report gui without exceptions");
            
            &Tkx::MainLoop();
    
            pass("gui stopped without exceptions");
        } catch {
            ERROR($_);
            fail($_);
        };
    };

}

1;