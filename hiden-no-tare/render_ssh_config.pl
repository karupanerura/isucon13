#!/usr/bin/env perl
use strict;
use warnings;
use feature qw/say/;

use JSON::PP qw/decode_json/;

my $stack_name = shift @ARGV;

my $cloudformation = decode_json(scalar `aws --output=json cloudformation describe-stack-resources --stack-name $stack_name`);
my @instance_ids = map { $_->{PhysicalResourceId} } grep { $_->{ResourceType} eq 'AWS::EC2::Instance' } @{ $cloudformation->{StackResources} };

my $ec2 = decode_json(scalar `aws --output=json ec2 describe-instances --instance-ids @instance_ids`);
my @instances = map { @{ $_->{Instances} } } @{ $ec2->{Reservations} };

my %config;
for my $instance (@instances) {
    my ($name) = map { $_->{Value} } grep { $_->{Key} eq 'Name' } @{ $instance->{Tags} };
    $config{$name} = <<__EOD__;
Host $name
    HostName $instance->{PublicIpAddress}
    User isucon 
    ServerAliveInterval 60
__EOD__
}

for my $name (sort keys %config) {
    say $config{$name};
}