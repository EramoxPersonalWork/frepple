#!/usr/bin/perl
#  file     : $HeadURL: file:///develop/SVNrepository/frepple/trunk/test/scalability_2/runtest.pl $
#  revision : $LastChangedRevision$  $LastChangedBy$
#  date     : $LastChangedDate$
#  email    : jdetaeye@users.sourceforge.net


# This script is a simple, generic model generator. A number of different
# models are created with varying number of clusters, depth of the supply path
# and number of demands per cluster. By evaluating the runtime of these models
# we can evaluate different aspects of Frepple's scalability.
#
# This test script is meant more as a sample for your own tests on evaluating
# scalability.
#
# The autogenerated supply network looks schematically as follows:
#   [ Operation -> buffer ] ...   [ -> Operation -> buffer ]  [ Delivery ]
#   [ Operation -> buffer ] ...   [ -> Operation -> buffer ]  [ Delivery ]
#   [ Operation -> buffer ] ...   [ -> Operation -> buffer ]  [ Delivery ]
#   [ Operation -> buffer ] ...   [ -> Operation -> buffer ]  [ Delivery ]
#   [ Operation -> buffer ] ...   [ -> Operation -> buffer ]  [ Delivery ]
#       ...                                  ...
# Each row represents a cluster.
# The operation+buffer are repeated as many times as the depth of the supply
# path parameter.
# In each cluster a single item is defined, and a parametrizable number of
# demands is placed on the cluster.


use strict;
use warnings;

use Env qw(EXECUTABLE);
use Time::HiRes qw ( gettimeofday tv_interval );


# This function generates a random date
sub getDate()
{
  my ($month,$day) = ( int(rand(12)+1), int(rand(28)+1) );
  if ($month < 10) { $month = "0$month"; }
  if ($day < 10) { $day = "0$day"; }
  return "2006-${month}-${day}T00:00:00";
}


# This routine creates the model data file.
# The return value is an indication of the size of the model.
sub create ($;$;$;$)
{
  # Pick up the parameters
  my ($cluster,$demand,$level,$file) = @_;

  # Initialize
  my $size = 0;
  open(OUT, ">$file") or die "Can't write to file $file: $!";
  print OUT "<PLAN xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n";

  # Items
  print OUT "<ITEMS>\n";
  for (my $i=1; $i<=$cluster; $i+=1)
  {
    $size++;
    my $it = sprintf("%05d",$i);
    print OUT "<ITEM NAME=\"Item C$it\">" .
      "<OPERATION NAME=\"Del C$it\"> <FLOWS>" .
        "<FLOW xsi:type=\"FLOW_START\" QUANTITY=\"-1\">" .
        "<BUFFER NAME=\"Buffer C${it} L01\">" .
           "<LOCATION NAME=\"Level 01\"/>" .
           "<ITEM NAME=\"Item C${it}\"/>" .
        "</BUFFER></FLOW>" .
      "</FLOWS></OPERATION></ITEM>\n";
  }
  print OUT "</ITEMS>\n";

  # Demands
  print OUT "<DEMANDS>\n";
  for (my $i=1; $i<=$cluster; $i+=1)
  {
    my $it = sprintf("%05d",$i);
    for (my $j=1; $j<=$demand; $j+=1)
    {
      $size += 2; # since a demand will result in multiple operationplans
      print OUT "<DEMAND NAME=\"Demand C${it} D${j}\" " .
        "QUANTITY=\"1\" DUE=\"" . getDate() . "\">" .
        "<ITEM NAME=\"Item C$it\"/></DEMAND>\n";
    }
  }
  print OUT "</DEMANDS>\n";

  # Operations
  print OUT "<OPERATIONS>\n";
  for (my $i=1; $i<=$cluster; $i+=1)
  {
    my $it = sprintf("%05d",$i);
    for (my $j=1; $j<=$level; $j+=1)
    {
      $size += 2;
      my $k = $j + 1;
      my $jt = sprintf("%02d",$j);
      my $kt = sprintf("%02d",$k);
      print OUT "<OPERATION NAME=\"Oper C${it} O${jt}\" " .
        "xsi:type=\"OPERATION_FIXED_TIME\" " .
        "DURATION=\"" . (24*int(rand(10)+1)) . ":00:00\"> <FLOWS>" .
        "<FLOW xsi:type=\"FLOW_END\" QUANTITY=\"1\">" .
        "<BUFFER NAME=\"Buffer C${it} L${jt}\">" .
        "<PRODUCING NAME=\"Oper C${it} O${jt}\"/></BUFFER></FLOW>" .
        "<FLOW xsi:type=\"FLOW_START\" QUANTITY=\"-1\">" .
        "<BUFFER NAME=\"Buffer C${it} L${kt}\">" .
        "<LOCATION NAME=\"Level ${kt}\"/>" .
        "<ITEM NAME=\"Item C${it}\"/>" .
	"</BUFFER></FLOW>" .
        "</FLOWS></OPERATION>\n";
    }
  }

  # Create material supply
  my $supplylevel = sprintf("%02d", $level + 1);
  my $supplyqty = $demand;
  for (my $i=1; $i<=$cluster; $i+=1)
  {
    my $it = sprintf("%05d",$i);
    print OUT "<OPERATION NAME=\"Supply C${it}\"> " .
        "<FLOWS><FLOW xsi:type=\"FLOW_END\" QUANTITY=\"1\">" .
        "<BUFFER NAME=\"Buffer C${it} L${supplylevel}\"/>" .
        "</FLOW></FLOWS></OPERATION>";
  }
  print OUT "</OPERATIONS>\n<OPERATION_PLANS>\n";
  for (my $i=1; $i<=$cluster; $i+=1)
  {
    my $it = sprintf("%05d",$i);
    print OUT "<OPERATION_PLAN ID=\"${i}\" OPERATION=\"Supply C${it}\" " .
        "START=\"2006-05-01T00:00:00\" QUANTITY=\"${supplyqty}\" " .
        "LOCKED=\"true\" />\n";
  }
  print OUT "</OPERATION_PLANS>";

  # Tail of the output file
  print OUT "</PLAN>\n";
  close(OUT);

  # Return size indication
  return $size;
}


# Pick up the command line arguments
my ($cluster, $level, $demand, $file) = @ARGV;
if (!defined $cluster || !defined $level || !defined $demand || !defined $file)
{
  print "Incorrect number of arguments\n\n";
  print "Usage:\n  createmodel.pl <clusters> <levels> <demands> <filename>\n\n";
  die;
}

# Initialize random number generator in a reproducible way
srand(100);

# Generate a message
print "Creating a model with $cluster clusters, " .
  "$level levels, and $demand demands per cluster in file $file\n";

# Create the model
create($cluster, $demand, $level, $file);

exit;
