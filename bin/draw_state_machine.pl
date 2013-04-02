#!/usr/bin/perl

use strict;
use warnings;
use gv;

my $fn = shift @ARGV;

our %state_machines;
do $fn;

use Class::StateMachine::Declarative::Graphviz;

while (my ($class, $decl) = each %state_machines) {
    my $graph = gv::digraph($class);
    my $drawer = Class::StateMachine::Declarative::Graphviz->new;
    # UNIVERSAL::isa($decl, 'HASH') and $decl = [%$decl];
    $drawer->draw_state_machine($graph, $class, $decl);
    $graph->gv::write("$class.dot");
}

