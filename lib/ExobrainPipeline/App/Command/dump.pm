package ExobrainPipeline::App::Command::dump;

use strict;
use warnings;

use Data::Dumper;
use ExobrainPipeline::App -command;

# ABSTRACT: Load ExobrainPipeline and then dump it

sub execute {
    my ($self, $opt, $args) = @_;

    print Dumper $self->app->exobrain();

}

sub description {
  return "Load and then dump the ExobrainPipeline.";
}

1;
