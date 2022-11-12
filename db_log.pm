use 5.14.0;
package db_log;
use strict;
use warnings;
use base qw(Exporter);

our @EXPORT = qw(
    db_connect
    clear_log
);


use DBI;


# our $DSN = "dbi:mysql:host=127.0.0.23:database=gazprombank_test_task";
our $DSN = "dbi:mysql:host=localhost:database=gazprombank_test_task";
our $db_user = 'cgi';
our $db_pwd = '';


sub db_connect {
    return DBI->connect(
        $DSN, $db_user, $db_pwd,
        { RaiseError => 1 }
    );
}


sub clear_log {
    my ($dbh) = @_;
    $dbh->do(<<"SQL");
        DELETE FROM message
SQL
    $dbh->do(<<"SQL");
        DELETE FROM log
SQL
}


1;
