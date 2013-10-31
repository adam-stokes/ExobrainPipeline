package ExobrainPipeline::App;

use strict;
use warnings;

use App::Cmd::Setup 0.309 -app;

sub exobrain {
    my ($self) = @_;
    require ExobrainPipeline::Builder;
    return ExobrainPipeline::Builder->from_config;
}

1;
