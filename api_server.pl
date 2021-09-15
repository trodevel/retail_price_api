#
# API server.
#
# Copyright (C) 2021 Dr. Sergey Kolevatov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

use utf8;

use Mojolicious::Lite;
use Mojo::JWT;

use 5.20.0;
use experimental 'signatures';

my $payload = {id => 1, api_key => '1a2b3c4d5e6f7a8b9c'};

# helpers
helper 'jwt_encode' => sub ($c, $payload = {}) {
  return Mojo::JWT->new(claims => $payload, secret => 's3cr3t')->encode;
};

helper 'jwt_decode' => sub ($c, $jwt) {
  return Mojo::JWT->new(secret => 's3cr3t')->decode($jwt);
};

helper 'authenticated' => sub ($c) {
  my $jwt = $c->param('jwt');
  $jwt = $c->jwt_decode($jwt);
  return $jwt->{api_key} eq $payload->{api_key} ? 1 : 0;
};



# POST /v1/login
# Testing: curl -XPOST http://localhost:3000/v1/login -d 'email=test@test.com&password=test'
post '/v1/login' => sub ($c) {
  my $email = $c->param('email');
  my $password = $c->param('password');

  # error
  unless($email eq 'test@test.com' && $password eq 'test') {
    return $c->render(
      json => {error => 'invalid_username_or_password'},
      status => 400
    )
  }

  return $c->render(
    json => {api_token => $c->jwt_encode($payload)},
    status => 200
  )
};


under sub($c) {
  my $jwt = $c->param('api_token') || '';
  $jwt = eval { $c->jwt_decode($jwt) };
  return 1 if $jwt && $jwt->{api_key} eq $payload->{api_key};

  # Not authenticated
  $c->render(
    json => { error => 'unauthenticated' },
    status => 401
  );
  return undef
};

# GET /v1/dashboard
# Testing: curl -XGET http://localhost:3000/v1/dashboard -d 'api_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlfa2V5IjoiMWEyYjNjNGQ1ZTZmN2E4YjljIiwiaWQiOjF9.LWjXWE0yptTp7xGwxS0YMAMUWfRXzSlpslDIaskaFBE'
get '/v1/dashboard' => sub ($c) {
  my $jwt = $c->param('api_token');
  return $c->render(
    json => { current_user => $c->jwt_decode($c->param('api_token')) },
    status => 200
  )
};

my @shops=qw(Rewe Alnatura dm);

get '/v1/shops' => sub ($c) {
  my $jwt = $c->param('api_token');
  return $c->render(
    json => { shops => \@shops },
    status => 200
  )
};

my @rewe_products=qw( Apfel Birne Banane Brot );

get '/v1/(:shop_id)/products' => sub ($c) {
  my $jwt = $c->param('api_token');

  my $shop_id = $c->stash('shop_id');

  return $c->render(
    json => { shop => $shop_id, products => \@rewe_products },
    status => 200
  )
};

app->start;
