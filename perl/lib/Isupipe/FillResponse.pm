package Isupipe::FillResponse;
use v5.38;
use utf8;

use Exporter 'import';

our @EXPORT_OK = qw(
    fill_user_response
    fill_livestream_response
    fill_livecomment_response
    fill_livecomment_report_response
    fill_reaction_response
);

use Carp qw(croak);

use Isupipe::Entity::User;
use Isupipe::Entity::Tag;
use Isupipe::Entity::Livestream;
use Isupipe::Entity::LivestreamTag;
use Isupipe::Entity::Livecomment;
use Isupipe::Entity::Reaction;

use Isupipe::Icon qw(
    FALLBACK_IMAGE_HASH_PATH
);

sub fill_user_response($app, $user) {
    my $theme = $app->dbh_r->select_row_as(
        'Isupipe::Entity::Theme',
        'SELECT * FROM themes WHERE user_id = ?',
        $user->id,
    );
    unless ($theme) {
        croak 'Theme not found:', $user->id;
    }

    my $username = $user->name;
    my $icon_hash = do {
        local $/;
        my $fh;
        open $fh, '<', "/home/isucon/icons/$username.sha256"
            or open $fh, '<', FALLBACK_IMAGE_HASH_PATH
            or die "Cannot open icon hash file: $!";
        <$fh>;
    };

    return Isupipe::Entity::User->new(
        id           => $user->id,
        name         => $user->name,
        display_name => $user->display_name,
        description  => $user->description,
        theme        => $theme,
        icon_hash    => $icon_hash,
    );
}

sub fill_livestream_response($app, $livestream) {
    my $owner = $app->dbh_r->select_row_as(
        'Isupipe::Entity::User',
        'SELECT * FROM users WHERE id = ?',
        $livestream->user_id,
    );
    unless ($owner) {
        croak 'Owner not found:', $livestream->user_id;
    }
    $owner = fill_user_response($app, $owner);

    my $livestream_tags = $app->dbh_r->select_all(
        'SELECT tag_id FROM livestream_tags WHERE livestream_id = ?',
        $livestream->id,
    ) || [];

    my $tags = [];
    if (scalar @$livestream_tags) {
        my @tag_ids = map { $_->{tag_id} } @$livestream_tags;
        $tags = $app->dbh_r->select_all_as(
            'Isupipe::Entity::Tag',
            'SELECT * FROM tags WHERE id IN (?)',
            \@tag_ids,
        );
    }
    if (scalar @$tags != scalar @$livestream_tags) {
        croak 'Tag not found';
    }

    return Isupipe::Entity::Livestream->new(
        id            => $livestream->id,
        owner         => $owner,
        title         => $livestream->title,
        tags          => $tags,
        description   => $livestream->description,
        playlist_url  => $livestream->playlist_url,
        thumbnail_url => $livestream->thumbnail_url,
        start_at      => $livestream->start_at,
        end_at        => $livestream->end_at,
    );
}

sub fill_livecomment_response($app, $livecomment) {
    my $user = $app->dbh_r->select_row_as(
        'Isupipe::Entity::User',
        'SELECT * FROM users WHERE id = ?',
        $livecomment->user_id,
    );
    my $comment_owner = fill_user_response($app, $user);

    my $livestream = $app->dbh_r->select_row_as(
        'Isupipe::Entity::Livestream',
        'SELECT * FROM livestreams WHERE id = ?',
        $livecomment->livestream_id,
    );
    $livestream = fill_livestream_response($app, $livestream);

    return Isupipe::Entity::Livecomment->new(
        id          => $livecomment->id,
        user        => $comment_owner,
        livestream  => $livestream,
        comment     => $livecomment->comment,
        tip         => $livecomment->tip,
        created_at  => $livecomment->created_at,
    );
}

sub fill_livecomment_report_response($app, $livecomment_report) {
    my $reporter = $app->dbh_r->select_row_as(
        'Isupipe::Entity::User',
        'SELECT * FROM users WHERE id = ?',
        $livecomment_report->user_id,
    );
    $reporter = fill_user_response($app, $reporter);

    my $livecomment = $app->dbh_r->select_row_as(
        'Isupipe::Entity::Livecomment',
        'SELECT * FROM livecomments WHERE id = ?',
        $livecomment_report->livecomment_id,
    );
    $livecomment = fill_livecomment_response($app, $livecomment);

    return Isupipe::Entity::LivecommentReport->new(
        id          => $livecomment_report->id,
        reporter    => $reporter,
        livecomment => $livecomment,
        created_at  => $livecomment_report->created_at,
    );
}

sub fill_reaction_response($app, $reaction) {
    my $user = $app->dbh_r->select_row_as(
        'Isupipe::Entity::User',
        'SELECT * FROM users WHERE id = ?',
        $reaction->user_id,
    );
    $user = fill_user_response($app, $user);

    my $livestream = $app->dbh_r->select_row_as(
        'Isupipe::Entity::Livestream',
        'SELECT * FROM livestreams WHERE id = ?',
        $reaction->livestream_id,
    );
    $livestream = fill_livestream_response($app, $livestream);

    return Isupipe::Entity::Reaction->new(
        id          => $reaction->id,
        emoji_name  => $reaction->emoji_name,
        user        => $user,
        livestream  => $livestream,
        created_at  => $reaction->created_at,
    );
}

