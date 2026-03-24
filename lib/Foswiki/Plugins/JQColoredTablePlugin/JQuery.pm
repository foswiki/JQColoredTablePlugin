# Extension for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# JQColoredTablePlugin is Copyright (C) 2024-2026 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::JQColoredTablePlugin::JQuery;

use strict;
use warnings;

use Foswiki::Plugins::JQueryPlugin::Plugin ();
use Foswiki::Plugins::JQColoredTablePlugin ();
our @ISA = qw( Foswiki::Plugins::JQueryPlugin::Plugin );

sub new {
  my $class = shift;

  my $this = bless(
    $class->SUPER::new(
      name => 'ColoredTable',
      version => $Foswiki::Plugins::JQColoredTablePlugin::VERSION,
      author => 'Michael Daum',
      homepage => 'http://foswiki.org/Extensions/JQColoredTablePlugin',
      javascript => ['coloredTable.js'],
      puburl => '%PUBURLPATH%/%SYSTEMWEB%/JQColoredTablePlugin',
      dependencies => ['moment'],
    ),
    $class
  );

  return $this;
}

1;
