package ExobrainPipeline::MVP::Section;
use Moose;
extends 'Config::MVP::Section';
# ABSTRACT: a standard section in ExobrainPipeline's configuration sequence

use namespace::autoclean;

use Config::MVP::Section 2.200002; # for not-installed error

use Moose::Autobox;

after finalize => sub {
  my ($self) = @_;

  my ($name, $plugin_class, $arg) = (
    $self->name,
    $self->package,
    $self->payload,
  );

  my %payload = %{ $self->payload };

  $plugin_class->register_component($name, \%payload, $self);

  return;
};

__PACKAGE__->meta->make_immutable;
1;
