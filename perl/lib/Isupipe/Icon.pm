package Isupipe::Icon;
use v5.38;
use utf8;

use File::stat ();
use Digest::SHA qw(sha256_hex);

use Exporter 'import';

our @EXPORT_OK = qw(
    FALLBACK_IMAGE_PATH
    FALLBACK_IMAGE_HASH_PATH
);

use constant FALLBACK_IMAGE_PATH => "../img/NoImage.jpg";
use constant FALLBACK_IMAGE_HASH_PATH  => "../img/NoImage.sha256";

sub read_fallback_user_icon_image {
    open my $fh, '<:raw', FALLBACK_IMAGE_PATH or die "Cannot open FALLBACK_IMAGE: $!";
    my $image = do { local $/; <$fh> };
    return $image;
}
