package ExobrainPipeline::Plugin::Taskwarrior;
use Moose;
with 'ExobrainPipeline::Role::Plugin';

use 5.010;
use Moose::Autobox;
use namespace::autoclean;

has cmd   => ( is => 'ro', isa => 'Str', required => 1 );
has title => ( is => 'ro', isa => 'Str', default  => 'Task Warrior' );

sub execute {
    my ( $self, $data ) = @_;

    my $output = `$self->{cmd}`;

    my $txt
        = $self->title . "\n"
        . '=' x length( $self->title ) . "\n"
        . $output . "\n";

    my $html = "<h1>" . $self->title . "</h1>\n<pre>$output</pre>\n";

    $data->push( { agenda => { text => $txt, html => $html } } );

    return $data;
}

1;

__END__

[Taskwarrior]
cmd = /usr/local/bin/task
