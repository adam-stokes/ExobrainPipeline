package ExobrainPipeline::App::Command::just;

use 5.010;
use strict;
use warnings;

use Data::Dumper;
use ExobrainPipeline::App -command;

# ABSTRACT: run a single plugin dumping it's output

sub description {
    return "Initialize ExobrainPipeline, execute a plugin and dump it's output";
}

sub execute {
    my ( $self, $opt, $args ) = @_;
    print Dumper
        $self->app->exobrain->plugin_named( $args->[0] )->execute( [] )->[0];
}

1;
