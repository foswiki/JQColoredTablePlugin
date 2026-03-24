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

package Foswiki::Plugins::JQColoredTablePlugin;

=begin TML

---+ package Foswiki::Plugins::JQColoredTablePlugin

plugin class to hook into the foswiki core

=cut

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Plugins::JQueryPlugin ();

our $VERSION = '1.00';
our $RELEASE = '%$RELEASE%';
our $SHORTDESCRIPTION = 'Colorize cells of a table based on their content';
our $LICENSECODE = '%$LICENSECODE%';
our $NO_PREFS_IN_TOPIC = 1;
our $core;


=begin TML

---++ initPlugin($topic, $web, $user) -> $boolean

initialize the plugin, automatically called during the core initialization process

=cut

sub initPlugin {

  Foswiki::Func::registerTagHandler('COLOREDTABLE', sub { return getCore()->COLOREDTABLE(@_); });
  Foswiki::Func::registerTagHandler('ENDCOLOREDTABLE', sub { return getCore()->ENDCOLOREDTABLE(@_); });

  Foswiki::Plugins::JQueryPlugin::registerPlugin('ColoredTable', 'Foswiki::Plugins::JQColoredTablePlugin::JQuery');

  return 1;
}

=begin TML

---++ finishPlugin

finish the plugin and the core if it has been used,
automatically called during the core initialization process

=cut

sub finishPlugin {
  $core->finish() if $core;
  undef $core;
}

=begin TML

---++ getCore() -> $core

returns a singleton core object for this plugin

=cut

sub getCore {
  unless (defined $core) {
    require Foswiki::Plugins::JQColoredTablePlugin::Core;
    $core = Foswiki::Plugins::JQColoredTablePlugin::Core->new();
  }
  return $core;
}

1;
