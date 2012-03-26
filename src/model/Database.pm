use strict;
use warnings;

package Database;
use DBI;
use Log::Log4perl qw(:easy);


my $database    = "finance";
my $user        = "financeclient";
my $password    = "financeclient";
my $dbh;


sub getDBConnection {
	if(!$dbh) {
		&_connect();
	}
	return $dbh;
}



sub _connect {
    INFO("attempting to connect to database");
    $dbh = DBI->connect("DBI:mysql:" . $database, 
        $user, $password, {RaiseError => 1});
    INFO("database connection succeeded -- $database $user");
}


1;