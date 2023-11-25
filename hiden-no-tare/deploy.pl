#!/usr/bin/env perl
use strict;
use warnings;
use feature qw/say/;

use FindBin;
use File::Spec;
use JSON::PP qw/encode_json/;

my $LOCAL_BASE_DIR = File::Spec->catdir($FindBin::Bin, File::Spec->updir);
my $REMOTE_BASE_DIR = '/home/isucon/webapp';

my $WITH_ENV_SH = 1;
my @TARGET_DIRS = qw(perl img pdns sql);
my @TARGET_HOSTS = qw(isucon13-final-3);

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
    if ($WITH_ENV_SH) {
        # env.sh
        my $local_file = File::Spec->catfile($LOCAL_BASE_DIR, 'env.sh');
        my $remote_file = File::Spec->catfile($REMOTE_BASE_DIR, File::Spec->updir, 'env.sh');
        system 'scp', '-C', "$local_file", "$host:$remote_file";
        system 'curl', '-X', 'POST',
            '-H', 'Content-type: application/json',
            '-d', encode_json({ text => "[DEPLOY] env.sh -> $host by $ENV{USER}" }),
            'https://hooks.slack.com/services/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';
    }
    for my $dir (@TARGET_DIRS) {
        my $local_dir = File::Spec->catdir($LOCAL_BASE_DIR, $dir);
        my $remote_dir = File::Spec->catdir($REMOTE_BASE_DIR, $dir);
        my @additional_rsync_opts;
        push @additional_rsync_opts => "--exclude", "local" if $dir eq 'perl';
        system 'rsync', '-avucz', '-e', 'ssh', @additional_rsync_opts, "$local_dir/", "$host:$remote_dir";
        system 'ssh', '-n', $host, File::Spec->catfile($REMOTE_BASE_DIR, $dir, 'post_deploy.sh') if $dir eq 'perl';
        system 'curl', '-X', 'POST',
            '-H', 'Content-type: application/json',
            '-d', encode_json({ text => "[DEPLOY] $dir -> $host by $ENV{USER}" }),
            'https://hooks.slack.com/services/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';
    }
}
