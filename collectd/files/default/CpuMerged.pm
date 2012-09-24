package Collectd::Plugins::CpuMerged;

use strict;
use warnings;
use Switch;

use Collectd qw( :all );

sub cpu_read
{
  my $vl = { 'host'=>$hostname_g, 'interval' =>$interval_g, 'time'=> time(), plugin => 'cpumerged'};
  open(ST, "/proc/stat") or return 0;
  while (<ST>)
  {
    next unless /^cpu /;
    my @values = /^cpu\s+(\d+)\s(\d+)\s(\d+)\s(\d+)\s(\d+)\s(\d+)\s(\d+)\s(\d+).+/;
    for(my $i=0; $i<scalar(@values); $i++)
    {
      my $type = "";
      switch($i)
      {
        case 0  { $type = "user"; }
        case 1  { $type = "nice"; }
        case 2  { $type = "system"; }
        case 3  { $type = "idle"; }
        case 4  { $type = "wait"; }
        case 5  { $type = "interrupt"; }
        case 6  { $type = "softirq"; }
        case 7  { $type = "steal"; }
        else  { $type = ""; }
      }

      if ($type)
      {
        $vl->{'values'} = [ $values[$i] ];
        $vl->{'type'} = $type;
        plugin_dispatch_values($vl);
      }
    }
  }
  close ST;
  return 1;
}

sub cpu_write
{
  my ($type, $ds, $vl) = @_;
  for (my $i = 0; $i < scalar (@$ds); ++$i) 
  {
    print "$vl->{'plugin'} ($vl->{'type'}): $vl->{'values'}->[$i]\n";
  }
  return 1;
}
plugin_register (TYPE_DATASET, "user", [{ name => 'user', type => DS_TYPE_COUNTER, min => 0, max => 4294967295 }]);
plugin_register (TYPE_DATASET, "nice", [{ name => 'user', type => DS_TYPE_COUNTER, min => 0, max => 4294967295 }]);
plugin_register (TYPE_DATASET, "system", [{ name => 'user', type => DS_TYPE_COUNTER, min => 0, max => 4294967295 }]);
plugin_register (TYPE_DATASET, "idle", [{ name => 'user', type => DS_TYPE_COUNTER, min => 0, max => 4294967295 }]);
plugin_register (TYPE_DATASET, "wait", [{ name => 'user', type => DS_TYPE_COUNTER, min => 0, max => 4294967295 }]);
plugin_register (TYPE_DATASET, "interrupt", [{ name => 'user', type => DS_TYPE_COUNTER, min => 0, max => 4294967295 }]);
plugin_register (TYPE_DATASET, "softirq", [{ name => 'user', type => DS_TYPE_COUNTER, min => 0, max => 4294967295 }]);
plugin_register (TYPE_DATASET, "steal", [{ name => 'user', type => DS_TYPE_COUNTER, min => 0, max => 4294967295 }]);
plugin_register (TYPE_READ, "cpumerged", "cpu_read");
plugin_register (TYPE_WRITE, "cpumerged", "cpu_write");
1;
