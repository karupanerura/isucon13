package Isupipe::Icon;
use v5.38;
use utf8;

use File::stat ();
use Digest::SHA qw(sha256_hex);

use Exporter 'import';

our @EXPORT_OK = qw(
    generate_icon_hash
    FALLBACK_IMAGE_PATH
);

use constant FALLBACK_IMAGE_PATH => "../img/NoImage.jpg";

sub read_fallback_user_icon_image {
    open my $fh, '<:raw', FALLBACK_IMAGE_PATH or die "Cannot open FALLBACK_IMAGE: $!";
    my $image = do { local $/; <$fh> };
    return $image;
}

sub generate_icon_hash {
    my ($username) = @_;

    open my $fh, '<:raw', "/home/isucon/icons/${username}.jpeg" or return sha256_hex(read_fallback_user_icon_image());

    my $image = do { local $/; <$fh> };
    return sha256_hex($image);
}
