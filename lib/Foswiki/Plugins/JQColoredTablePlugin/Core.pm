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

package Foswiki::Plugins::JQColoredTablePlugin::Core;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Plugins::JQueryPlugin ();

use constant TRACE => 0; # toggle me

sub new {
  my $class = shift;

  my $this = bless({
    @_
  }, $class);

  $this->{_insideColoredTable} = 0;
  return $this;
}

sub finish {
  my $this = shift;

  # undef $this->{_...};
}

sub COLOREDTABLE {
  my ($this, $session, $params, $topic, $web) = @_;

  return _inlineError("already inside a colored table section")
    if $this->{_insideColoredTable};
  $this->{_insideColoredTable} = 1;

  Foswiki::Plugins::JQueryPlugin::createPlugin("ColoredTable");

  my $result = "<div class='jqColoredTable' data-select='\$select' data-highlight='\$highlight' data-check-type='\$type' data-keywords='\$keywords' data-case-sensitive='\$caseSensitive' data-styles='\$styles' data-classes='\$classes' data-default-styles='\$defaultStyles' data-default-classes='\$defaultClasses'>";

  my $select = $params->{select} // 'null';
  $result =~ s/\$select\b/$select/g;

  my $highlight = $params->{highlight} // 'this';
  $result =~ s/\$highlight\b/$highlight/g;

  my $checkType = $params->{type} // 'string';
  $result =~ s/\$type\b/$checkType/g;

  my $caseSensitive = Foswiki::Func::isTrue($params->{casesensitive}, 0) ? "true": "false";
  $result =~ s/\$caseSensitive\b/$caseSensitive/g;

  my $defaultStyles = $params->{style} // '';
  $result =~ s/\$defaultStyles\b/$defaultStyles/g;

  my $defaultClasses = $params->{class} // '';
  $result =~ s/\$defaultClasses\b/$defaultClasses/g;

  my %htmlData = (
    keyword => [],
    style => [],
    class => [],
  );

  foreach my $p (keys %$params) {
    next unless $p =~ /^(keyword|style|class)_(\d+)$/;
    my $key = $1;
    my $index = $2;
    my $val = $params->{$p};
    $htmlData{$key}[$index-1] = $val;
  }

  foreach my $prop (qw(keyword style class)) {
    foreach my $item (@{$htmlData{$prop}}) {
      $item //= "";
    }
  }

  my $keywords = '[' . join(",", map {"\"$_\""} @{$htmlData{keyword}}) . ']';
  $result =~ s/\$keywords\b/$keywords/g;

  my $styles = '[' . join(",", map {"\"$_\""}  @{$htmlData{style}}) . ']';
  $result =~ s/\$styles\b/$styles/g;

  my $classes = '[' . join(",", map {"\"$_\""}  @{$htmlData{class}}) . ']';
  $result =~ s/\$classes\b/$classes/g;

  return $result;
}

sub ENDCOLOREDTABLE {
  my ($this, $session, $params, $topic, $web) = @_;

  return _inlineError("outside of a colored table section")
    unless $this->{_insideColoredTable};

  $this->{_insideColoredTable} = 0;

  return "</div>";
}

sub _inlineError {
  return "<span class='foswikiAlert'>ERROR: $_[0]</span>";
}

1;
