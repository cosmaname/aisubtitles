package aimage;

use Carp;
use OpenAPI::Client::OpenAI;
use Path::Tiny qw(path);
use MIME::Base64;
use Moo;
#use namespace::autoclean;
use Data::Dumper;

has system_message => (
  is => 'ro',
  default =>
    'You are an accessibility expert, able to describe images in Romanian for the visually impaired'
);

# gpt-4o-mini is smaller and cheaper than gpt4o, but it's still very good.
# Also, it's multi-modal, so it can handle images and some of the older
# vision models have now been deprecated.
has model       => ( is => 'ro', default => 'gpt-4o-mini' );
has temperature => ( is => 'ro', default => .1 );
has prompt      => (
  is      => 'ro',
  default => 'Descrie personajele din această imagine în trei propoziții'
);
has _client =>
  ( is => 'ro', default => sub { OpenAPI::Client::OpenAI->new } );

sub describe_image {
  my ($self,$filename) = @_;
  my $filetype = $filename =~ /\.png$/ ? 'png' : 'jpeg';
  my $image    = $self->_read_image_as_base64($filename);
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
              text => $self->prompt,
              type => 'text'
            },
            {
              type      => "image_url",
              image_url => {
                url => "data:image/$filetype;base64, $image"
              }
            }
          ],
        }
      ],
      temperature => $self->temperature,
    },
  };
  #say($message->{body}->{messages}[1]->{content}[0]->{text});
  my $response = $self->_client->createChatCompletion($message);
  return $self->_extract_description($response);
}

sub _extract_description {
  my ($self,$response) = @_;
  my $error = $response->res;
  my ($result, $e);
  my $json = $response->res->json;
  $result = $json->{choices}[0]{message}{content};
  return $result;
}

sub _read_image_as_base64 {
  my ($self, $file) = @_;
  my $content = Path::Tiny->new($file)->slurp_raw;

  # second argument is the line ending, which we don't
  # want as a newline because OpenAI doesn't like it
  return encode_base64( $content, '' );
}

1;
