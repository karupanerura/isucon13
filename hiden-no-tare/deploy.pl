#!/usr/bin/env perl
use strict;
use warnings;
use feature qw/say/;

use FindBin;
use File::Spec;
use JSON::PP qw/encode_json/;

my $LOCAL_BASE_DIR = File::Spec->catdir($FindBin::Bin, File::Spec->updir);
my $REMOTE_BASE_DIR = '/home/isucon';

my @TARGET_DIRS = qw(perl);
my @TARGET_HOSTS = qw(isu13q-1 isu13q-2 isu13q-3);

# check dir
for my $dir (@TARGET_DIRS) {
    die "not found dir $dir" unless -d File::Spec->catdir($LOCAL_BASE_DIR, $dir);
}

# check targets
for my $host (@TARGET_HOSTS) {
    system 'ssh', '-n', $host, 'true';
    die "cannot ssh to $host" unless $? == 0;
}

# confirm targets
say "[TARGETS]";
for my $host (@TARGET_HOSTS) {
    print "- $host";
    for my $dir (@TARGET_DIRS) {
        print " + $dir";
    }
    print $/;
}
print "Deploy? (y/n): ";
while (chomp(my $yn = <STDIN>)) {
    last if $yn eq 'y';
    exit if $yn eq 'n';
    print "Deploy? (y/n): ";
}

# do it
for my $host (@TARGET_HOSTS) {
    for my $dir (@TARGET_DIRS) {
        my $local_dir = File::Spec->catdir($LOCAL_BASE_DIR, $dir);
        my $remote_dir = File::Spec->catdir($REMOTE_BASE_DIR, $dir);
        system 'rsync', '-avucz', '-e', 'ssh', "$local_dir/", "$host:$remote_dir";
        system 'curl', '-X', 'POST',
            '-H', 'Content-type: application/json',
            '-d', encode_json({ text => "[DEPLOY] $dir -> $host by $ENV{USER}" }),
            'https://hooks.slack.com/services/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';
    }
}
