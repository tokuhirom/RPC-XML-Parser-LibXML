package RPC::XML::Parser::LibXML;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use base qw/Exporter/;
use RPC::XML;
use XML::LibXML;
use Encode;
use MIME::Base64;
use Carp;

our @EXPORT = qw/parse_rpc_xml/;

our $TYPE_MAP = +{
    int                => 'RPC::XML::int',
    i4                 => 'RPC::XML::int',
    boolean            => 'RPC::XML::boolean',
    string             => 'RPC::XML::string',
    double             => 'RPC::XML::double',
    'dateTime.iso8601' => 'RPC::XML::datetime_iso8601',
    base64             => 'RPC::XML::base64',
    array              => 'RPC::XML::array',
};

sub parse_rpc_xml {
    my $xml = shift;

    my $x = XML::LibXML->new;
    my $doc = $x->parse_string($xml)->documentElement;

    if ($doc->findnodes('/methodCall')) {
        return RPC::XML::request->new(
            $doc->findvalue('/methodCall/methodName'),
            _extract($doc->findnodes('//params/param/value/*'))
        );
    } elsif ($doc->findnodes('/methodResponse/params')) {
        return RPC::XML::response->new(
            _extract($doc->findnodes('//params/param/value/*'))
        );
    } elsif ($doc->findnodes('/methodResponse/fault')) {
        return RPC::XML::response->new(
            RPC::XML::fault->new(
                $doc->findvalue('/methodResponse/fault/value/struct/member/value/int'),
                encode('utf8', $doc->findvalue('/methodResponse/fault/value/struct/member/value/string')),
            ),
        );
    } else {
        croak "invalid xml: $xml";
    }
}

sub _extract {
    my @nodes = @_;

    my @args;

    for my $node (@nodes) {
        my $nodename = $node->nodeName;
        my $val = $node->textContent;

        if ($nodename eq 'base64')  {
            push @args, RPC::XML::base64->new(decode_base64($val));
        } elsif ($nodename eq 'struct') {
            my @members = $node->findnodes($node->nodePath . '/member'); # XXX
            my $result = {};
            for my $member (@members) {
                my ($trash, $name, $trash2, $value) = $member->childNodes;
                ($result->{encode 'utf8', $name->textContent}, ) = _extract($value->firstChild);
            }
            push @args, RPC::XML::struct->new($result);
        } elsif ($nodename eq 'array') {
            push @args, RPC::XML::array->new(_extract($node->findnodes($node->nodePath . '/data/value/*')));
        } else {
            my $class = $TYPE_MAP->{ $node->nodeName };
            push @args, $class->new(encode 'utf8', $val);
        }
    }

    return @args;
}

1;
__END__

=encoding utf8

=head1 NAME

RPC::XML::Parser::LibXML -

=head1 SYNOPSIS

    use RPC::XML::Parser::LibXML;

=head1 DESCRIPTION

RPC::XML::Parser::LibXML is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
