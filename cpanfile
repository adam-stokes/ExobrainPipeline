requires 'perl', '5.010';
requires 'App::Cmd', '0.309';
requires 'Path::Class';
requires 'Class::Load';
requires 'Moose';
requires 'MooseX::Types::Perl';
requires 'Config::MVP';
requires 'Config::MVP::Reader::INI';
requires 'MooseX::LazyRequire';
requires 'MooseX::SetOnce';
requires 'Moose::Util::TypeConstraints';
requires 'Moose::Autobox';
requires 'Params::Util';
requires 'MooseX::Types';
requires 'Try::Tiny';


# Plugin::AgendaEmail
suggests 'Email::Sender::Simple';
suggests 'Email::MIME::CreateHTML';

# Plugin::Basecamp
suggests 'Template';
suggests 'Time::Duration';
suggests 'WebService::BasecampX';
suggests 'DateTime::Format::ISO8601';

# Plugin::FitBit
suggests 'WebService::FitBit';
suggests 'DateTime';

# Plugin::ICal
suggests 'DateTime';
suggests 'HTTP::Tiny';
suggests 'Moose::Autobox';
suggests 'DateTime::Span';
suggests 'Data::ICal::DateTime';
suggests 'DateTime::Format::ICal';

# Plugin::GitHubContribs
suggests 'Net::GitHub', '0.54';

on test => sub {
    requires 'Test::More', '0.88';
};
