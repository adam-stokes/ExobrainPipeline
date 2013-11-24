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

=encoding utf-8

=head1 NAME

ExobrainPipeline::Plugin::AgendaEmail - send a daily agenda email

=head1 DESCRIPTION

Email output plugin for L<ExobrainPipeline>.  Looks for an C<agenda> key in the
data for previous run plugins.  Value for this key should either be a string of
plain text for inclusion in the email or a hash containing C<html> and C<txt>
keys for HTML and plain text parts.

=head1 CONFIGURATION

This plugin accepts the below configuration file keys. For details on
specifying transports for L<Email::Sender> see L<https://metacpan.org/pod/Email::Sender::Manual::QuickStart#specifying-transport-in-the-environment>.

=head3 to

Email address to send to.

=head3 from

Email address to send from.

=head3 subject

Subject for the email, defaults to 'Daily Agenda Email'.

=head1 DEPENDENCIES

L<Email::Sender::Simple> and L<Email::MIME::CreateHTML>.

=head1 AUTHOR

Mike Greb E<lt>michael@thegrebs.comE<gt>

=head1 COPYRIGHT

Copyright 2013- Mike Greb

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
