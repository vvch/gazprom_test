#!/usr/bin/perl

use 5.14.0;
use strict;
use warnings;
use autodie;

use DBI;
use CGI qw/:cgi charset/;
charset('UTF-8');

# Debug
use CGI::Carp 'fatalsToBrowser';

use FindBin;
use lib $FindBin::Bin;
use db_log;


sub escape_html {
    my ($s) = @_;
    for ($s) {
        s/\"/&quot;/;
        s/\&/&amp;/;
        s/\</&lt;/;
        s/\>/&gt;/;
    }
    return $s;
}


sub template {
    my ($addr, $body) = @_;
    $body //= '';
    $addr //= '';
    return <<"HTML";
<!doctype html>
<html>
<head>
<title>
    Поиск в логе по адресу получателя
</title>
</head>
<body>
<h1>
    Поиск в логе по адресу получателя
</h1>
<div>
<form>
    <label>
        Адрес получателя:
        <input type="text" name="addr" value="@{[ escape_html($addr) ]}">
    </label>
    <input type="submit" value="Поиск">
</form>
</div>
<p></p>
<div>
$body
</div>
</body>
</html>
HTML
}


my $addr = param('addr') || '';


if (!defined $addr) {
    #  Search form only
    print header, template;
    exit;
}



my $dbh = db_connect;


my $MAX_RECORDS = 100;

my $res = $dbh->selectall_arrayref(<<"SQL", {Columns=>{}}, $addr);
    SELECT created, str, int_id
    FROM log
    WHERE address = ?
    -- UNION
    -- SELECT created, str, int_id
    -- FROM message
    ORDER BY int_id, created
    LIMIT @{[$MAX_RECORDS + 1]}
SQL


my $warning = '';
if ( !$res ) {
    $warning =
        "Ошибка базы данных\n";
} elsif (scalar @$res == $MAX_RECORDS+1) {
    $warning =
        "Показаны только первые $MAX_RECORDS записей!\n";
    pop @$res;
} elsif (scalar @$res == 0) {
    $warning =
        "Записей, соответствующих заданным критериям, не найдено.\n";
}

# $warning = "записей: " . scalar @$res;


my $table = join '',
    map "<tr>\n<td>@{[escape_html($_->{created})]}</td><td>@{[escape_html($_->{str})]}</td>\n</tr>\n",
        @$res if scalar @$res != 0;

$table = <<"HTML" if $table;
<table border="1">
<thead>
<tr>
    <th>
        Дата
    </th>
    <th>
        Строка лога
    </th>
</tr>
</thead>
<tbody>
<tr>
$table
</tr>
</tbody>
</table>
HTML


$table = "<div class='warning'>\n\t$warning\n</div>\n$table"
    if $warning;

print header, template($addr, $table);


$dbh->disconnect;
