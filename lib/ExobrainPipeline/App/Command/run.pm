package ExobrainPipeline::App::Command::run;

use strict;
use warnings;

use Data::Dumper;
use ExobrainPipeline::App -command;

# ABSTRACT: Load and run ExobrainPipeline

sub execute {
    my ($self, $opt, $args) = @_;

    my $data = $self->app->exobrain->run;
    # print Dumper $data;

}

sub description {
  return "Load and run ExobrainPipeline";
}

1;
