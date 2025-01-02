package atranslate;

use v5.34.0;
use Moo;
use OpenAPI::Client::OpenAI;
use Path::Tiny qw(path);
use Data::Dumper;

has system_message => ( is => 'ro', default => 'You are an expert movie subtitle translator who translates English text to Romanian. You are going to be translating text from a subtitle file.' );
has model          => ( is => 'ro', default => 'gpt-3.5-turbo' );
has temperature    => ( is => 'ro', default => .1 );
has max_tokens     => ( is => 'ro', default => 2048 );
has prompt         => ( is => 'ro', default => 'I will give you lines of text, translate each line, to the best of your ability. Keep the time cues.' );
# 'I will give you lines of text in ASS format. Ignore the first 15 lines and the beggining of each line up to the last double comma separator. Output line numbers next to each. Translate each line, to the best of your ability:' );
has _client        => ( is => 'ro', default => sub { OpenAPI::Client::OpenAI->new } );

sub translate_file {
  my ($self,$filename) = @_;
  my $content = Path::Tiny->new($filename)->slurp_raw;
  my $text = $self->prompt . "\n\n" . $content;
  my $message  = {
    body => {
      model    => $self->model,
      messages => [
        {
          role    => 'system',
          content => $self->system_message,
        },
        {
          role    => 'user',
          content => [
            {
              text => $text,
              type => 'text'
            },
          ],
        }
      ],
      temperature => $self->temperature,
      max_tokens  => $self->max_tokens,
    },
  };
  $self->_client->ua->inactivity_timeout ( $self->max_tokens / 8 );
  my $response = $self->_client->createChatCompletion($message);
  if ( $response->result->is_success ) {
    return $self->_extract_translation($response);
  } else {
    say("Request was not successful:");
    local $Data::Dumper::Indent   = 1;
    local $Data::Dumper::Sortkeys = 1;
    die Dumper( $response->res );
  }
}

sub _extract_translation {
  my ($self,$response) = @_;
  my $translation;
  my $json = $response->result->json;
  $translation = $json->{choices}[0]{message}{content};
  return $translation;
}

1;
