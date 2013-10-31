package ExobrainPipeline::Builder;

use strict;
use warnings;

use Path::Class;
use Class::Load;

sub from_config {
    my ( $class, $arg ) = @_;
    $arg ||= {};

    my $root = dir( $arg->{home} || $ENV{HOME} || '.' );

    my $sequence = $class->_load_config(
        {   root            => $root,
            chrome          => $arg->{chrome},
            config_class    => $arg->{config_class},
            _global_stashes => $arg->{_global_stashes},
        } );

    my $self = $sequence->section_named('_')->exobrain;

    # $self->_setup_default_plugins;

    return $self;
}

sub _load_config {
    my ( $class, $arg ) = @_;
    $arg ||= {};

    my $root = $arg->{root} || '.';

    require Config::MVP::Reader::Finder;
    require ExobrainPipeline::MVP::Assembler::Exobrain;
    require ExobrainPipeline::MVP::Section;

    my $assembler = ExobrainPipeline::MVP::Assembler::Exobrain->new(
        section_class => 'ExobrainPipeline::MVP::Section'
    );
    # my $starting_section = $assembler->section_class->new( { name => '_' } );
    # $assembler->sequence->add_section($starting_section);

    # for ($assembler->sequence->section_named('_')) {
    #   $_->add_value(chrome => $arg->{chrome});
    #   $_->add_value(root   => $arg->{root});
    #   $_->add_value(_global_stashes => $arg->{_global_stashes})
    #     if $arg->{_global_stashes};
    # }

    my $seq = Config::MVP::Reader::Finder->read_config( $root->file('.exobrain'),
    { assembler => $assembler } );

  return $seq;
}

1;
