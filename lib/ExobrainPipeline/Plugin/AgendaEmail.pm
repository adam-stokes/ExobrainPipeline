package ExobrainPipeline::Plugin::AgendaEmail;
use Moose;
with 'ExobrainPipeline::Role::Plugin';

use 5.010;

use Moose::Autobox;
use Email::Sender::Simple;
use Email::MIME::CreateHTML;
use namespace::autoclean;

has to      => ( is => 'ro', isa => 'Str', required => 1 );
has from    => ( is => 'ro', isa => 'Str', required => 1 );
has subject => ( is => 'ro', isa => 'Str', default  => 'Daily Agenda Email' );

sub execute {
    my ( $self, $data ) = @_;

    my ( $html, $txt );
    for my $plugin ( $data->flatten ) {
        next unless $plugin->exists('agenda');

        if ( ref $plugin->{agenda} eq 'HASH' ) {
            $txt  .= $plugin->{agenda}{text} . "\n\n";
            $html .= $plugin->{agenda}{html} . "<br/><hr/>";
        }
        else {
            $txt  .= $plugin->{agenda} . "\n\n";
            $html .= "<pre>$plugin->{agenda}</pre><br/><hr/>\n";
        }

    }

    my $email = Email::MIME->create_html(
        header => [
            From    => $self->from,
            To      => $self->to,
            Subject => $self->subject,
        ],
        body      => $html,
        text_body => $txt
    );

    Email::Sender::Simple->try_to_send($email);

    return $data;
}

1;

__END__
See https://metacpan.org/pod/Email::Sender::Manual::QuickStart#specifying-transport-in-the-environment

[AgendaEmail]
to = you@example.com
from = you@example.com
