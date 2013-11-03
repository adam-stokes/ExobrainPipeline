package ExobrainPipeline::Plugin::Taskwarrior;
use Moose;
with 'ExobrainPipeline::Role::Plugin';

use 5.010;

use namespace::autoclean;

has cmd         => ( is => 'ro', isa => 'Str', required => 1 );
has title       => ( is => 'ro', isa => 'Str', default  => 'Task Warrior' );

sub execute {
    my ( $self, $data ) = @_;

    my $output = $self->title . "\n" . '=' x length( $self->title ) . "\n";
    $output .= `$self->{cmd}`;

    $data->push( { agenda => $output } );

    return $data;
}

1;

__END__

[Taskwarrior]
cmd = /usr/local/bin/task
