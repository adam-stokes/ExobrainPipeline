package ExobrainPipeline::MVP::Assembler;
use Moose;
extends 'Config::MVP::Assembler';

use namespace::autoclean;

sub expand_package {
    return 'ExobrainPipeline::Plugin::' . $_[1];
}

__PACKAGE__->meta->make_immutable;

1;