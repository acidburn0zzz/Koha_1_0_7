#!/usr/bin/perl

#written 14/1/2000
#script to display reports
#major rewrite by chris@katipo.co.nz 22/11/00

use C4::Stats;
use strict;
use Date::Manip;
use CGI;
use C4::Output;

my $input=new CGI;
my $time=$input->param('time');
print $input->header;

print startpage;
print startmenu('report');
print center;

my $date;
my $date2;
if ($time eq 'yesterday'){
  $date=ParseDate('yesterday');
  $date2=ParseDate('today');
}
if ($time eq 'today'){
  $date=ParseDate('today');
  $date2=ParseDate('tomorrow');
}
if ($time eq 'daybefore'){
  $date=ParseDate('2 days ago');
  $date2=ParseDate('yesterday');
}
if ($time=~ /\//){
  $date=ParseDate($time);
  $date2=ParseDateDelta('+ 1 day');
  $date2=DateCalc($date,$date2);
}
$date=UnixDate($date,'%Y-%m-%d');
$date2=UnixDate($date2,'%Y-%m-%d');

print mkheadr(1,"$date");
print mktablehdr;
print mktablerow(5,'white','<b>Branch</b>','<b>Issues</b>','<b>Returns</b>','<b>Renewals</b>','<b>Paid</b>');
my $issues=Count('issue','C',$date,$date2);
my $returns=Count('return','C',$date,$date2);
my $renew=Count('renew','C',$date,$date2);
my $paid=gettotals($date,$date2,'C');
print mktablerow(5,'white','<b>Levin</b>',$issues,$returns,$renew,$paid);
$issues=Count('issue','F',$date,$date2);
$returns=Count('return','F',$date,$date2);
$renew=Count('renew','F',$date,$date2);
$paid=gettotals($date,$date2,'F');
print mktablerow(5,'white','<b>Foxton</b>',$issues,$returns,$renew,$paid);
$issues=Count('issue','S',$date,$date2);
$returns=Count('return','S',$date,$date2);
$renew=Count('renew','S',$date,$date2);
$paid=gettotals($date,$date2,'S');
print mktablerow(5,'white','<b>Shannon</b>',$issues,$returns,$renew,$paid);
print mktableft;
print endmenu('report');
print endpage;
