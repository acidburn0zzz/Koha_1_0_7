#!/usr/bin/perl

#written 14/1/2000
#script to display reports

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
my @payments=TotalPaid($date);
my $count=@payments;
my $total=0;
my %levin;
my %foxton;
my %shannon;
#my $totalc=0;
#my $totalcf=0;
print mktablehdr;
print mktablerow(5,'#99cc33',bold('Name'),bold('Type'),bold('Date/time'),bold('Amount'), bold('Branch'),'/images/background-mem.gif');
for (my $i=0;$i<$count;$i++){
  my $hour=substr($payments[$i]{'timestamp'},8,2);
  my  $min=substr($payments[$i]{'timestamp'},10,2);
  my $sec=substr($payments[$i]{'timestamp'},12,2);
  my $time="$hour:$min:$sec";
  $payments[$i]{'amount'}*=-1;
  $total+=$payments[$i]{'amount'};
  my @charges=getcharges($payments[$i]{'borrowernumber'},$payments[$i]{'timestamp'});
  my $count=@charges;
  my $temptotalf=0;
  my $temptotalr=0;
  my $temptotalres=0;
  my $temptotalren=0;
  for (my $i2=0;$i2<$count;$i2++){
    print mktablerow(6,'red',$charges[$i2]->{'description'},$charges[$i2]->{'accounttype'},'',
    $charges[$i2]->{'amount'},$charges[$i2]->{'amountoutstanding'});
    if ($charges[$i2]->{'accounttype'} eq 'Rent'){
      $temptotalr+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
    }
    if ($charges[$i2]->{'accounttype'} eq 'F'){
      $temptotalf+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
    }
    if ($charges[$i2]->{'accounttype'} eq 'Res'){
      $temptotalres+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
    }
    if ($charges[$i2]->{'accounttype'} eq 'R'){
      $temptotalren+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
    }
    
  }                 
  my $time2="$payments[$i]{'date'} $time";
  my $branch=Getpaidbranch($time2);
  if ($branch eq 'C'){
    $levin{'total'}+=$payments[$i]{'amount'};
    $levin{'totalr'}+=$temptotalr;
    $levin{'totalres'}+=$temptotalres;
    $levin{'totalf'}+=$temptotalf;
    $levin{'totalren'}+=$temptotalren;
  }
  if ($branch eq 'F'){
    $foxton{'total'}+=$payments[$i]{'amount'};
    $foxton{'totalr'}+=$temptotalr;
    $foxton{'totalres'}+=$temptotalres;
    $foxton{'totalf'}+=$temptotalf;
    $foxton{'totalren'}+=$temptotalren;
  }
  if ($branch eq 'S'){
    $shannon{'total'}+=$payments[$i]{'amount'};
    $shannon{'totalr'}+=$temptotalr;
    $shannon{'totalres'}+=$temptotalres;
    $shannon{'totalf'}+=$temptotalf;
    $shannon{'totalren'}+=$temptotalren;
  }
  print mktablerow(6,'white',"$payments[$i]{'firstname'} <b>$payments[$i]{'surname'}</b>"
  ,$payments[$i]{'accounttype'},"$payments[$i]{'date'} $time",$payments[$i]{'amount'}
  ,$branch);
}
print mktableft;
print endcenter;
print "<p><b>$total</b>";
#print "<b
print mktablehdr;

print mktablerow(6,'white',"<b>Levin</b>","Fines $levin{'totalf'}","Rentals $levin{'totalr'}","Reserves $levin{'totalres'}","Renewals $levin{'totalren'}","Total $levin{'total'}");
print mktablerow(6,'white',"<b>foxton</b>","Fines $foxton{'totalf'}","Rentals $foxton{'totalr'}","Reserves $foxton{'totalres'}","Renewals $foxton{'totalren'}","Total $foxton{'total'}");
print mktablerow(6,'white',"<b>shannon</b>","Fines $shannon{'totalf'}","Rentals $shannon{'totalr'}","Reserves $shannon{'totalres'}","Renewals $shannon{'totalren'}","Total $shannon{'total'}");
print mktableft;
#my $issues=Count('issue','C',$date,$date2);
#print "<p>Issues Levin: $issues";
#$issues=Count('issue','F',$date,$date2);
#print "<br>Issues Foxton: $issues";
#$issues=Count('issue','S',$date,$date2);
#print "<br>Issues Shannon: $issues";
#my $returns=Count('return','C',$date,$date2);
#print "<p>Returns Levin: $returns";
#$returns=Count('return','F',$date,$date2);
#print "<br>Returns Foxton: $returns";
#$returns=Count('return','S',$date,$date2);
#print "<br>Returns Shannon: $returns";

print endmenu('report');
print endpage;
