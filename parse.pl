#!/usr/bin/perl

use 5.14.0;
use strict;
use warnings;
use autodie;

use DBI;

use FindBin;
use lib $FindBin::Bin;
use db_log;


my $counter = 0;

sub parse_log {
    my ($dbh, $file_name) = @_;
    open my $fh, '<', $file_name;
    for my $line (<$fh>) {
        chomp $line;
        my ($date, $time, $wo_tstamp)
            = split ' ', $line, 3;
        my ($int_id, $flag, $addr, $other)
            = split ' ', $wo_tstamp;
        for ($int_id, $flag, $addr, $other) {
            $_ //= '';
        }
        my $timestamp = "$date $time";

        my ($id) = $wo_tstamp =~ m/ id=(\S+)$/;
        $id //= '';

        if ( $flag eq '<=' && $id ne '' ) {  #  message arrival
            $dbh->do(<<"SQL", undef, $timestamp, $id, $int_id, $wo_tstamp);
                INSERT INTO message
                    (created, id, int_id, str)
                VALUES
                    (?,?,?,?)
SQL
        } else {
            $dbh->do(<<"SQL", undef, $timestamp, $int_id, $wo_tstamp, $addr);
                INSERT INTO log
                    (created, int_id, str, address)
                VALUES
                    (?,?,?,?)
SQL
        }
        say "$counter lines processed"
            if ++$counter % 500 == 0;
    }
    close $fh;
}


my $file_name = $ARGV[0];
$file_name //= './t/out';

my $dbh = db_connect;

# say "Clearing old records";
# clear_log($dbh);

say "Parsing $file_name ...";
parse_log($dbh, $file_name);
say "DONE.";

$dbh->disconnect;
