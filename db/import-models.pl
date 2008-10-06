#!/usr/bin/perl

use strict;
use diagnostics;
use warnings;

use DBI qw(:sql_types);
use DBD::Pg qw(:pg_types);
use File::Find;

# ------------------------------------------------------------
# Get import directories
# ------------------------------------------------------------
if ($#ARGV == -1)
{
    die "$0: You must provide at least one directory containing NetLogo models (.nlogo files).\n";
}

my @directories_to_search = @ARGV;

# ------------------------------------------------------------
# Connect to the database
# ------------------------------------------------------------

my $dbname = 'nlcommons_development';
my $dbuser = 'reuven';
my $dbpassword = '';

my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=localhost", '', '', {AutoCommit => 1,
                                                                        RaiseError => 1});

# ------------------------------------------------------------
# Set queries
# ------------------------------------------------------------

my $insert_model_node_sql =
    "INSERT INTO Nodes
        (node_type_id, parent_id, name, created_at, updated_at, visibility_id, changeability_id)
     VALUES
        ((SELECT id
            FROM Node_Types
           WHERE short_name = 'Model'),
         NULL, ?, NOW(), NOW(), 1, 1)";

my $insert_model_node_sth = $dbh->prepare($insert_model_node_sql);

my $insert_node_version_sql =
    "INSERT INTO Node_Versions
                (node_id, person_id, contents, description, created_at, updated_at)
             VALUES
                (?, 1, ?, ?, NOW(), NOW())";

my $insert_node_version_sth = $dbh->prepare($insert_node_version_sql);
$insert_node_version_sth->bind_param(2, undef, {pg_type => PG_BYTEA });

my $find_matching_model_sql = "SELECT id
                                 FROM Nodes
                                WHERE name = ?
                                  AND node_type = 1";
my $find_matching_model_sth = $dbh->prepare($find_matching_model_sql);

my $insert_preview_node_sql =
    "INSERT INTO Nodes
        (node_type_id, parent_id, name, created_at, updated_at, visibility_id, changeability_id)
     VALUES
        ((SELECT id
            FROM Node_Types
           WHERE short_name = 'Preview'),
         ?, ?, NOW(), NOW(), 1, 1)";

my $insert_preview_node_sth = $dbh->prepare($insert_preview_node_sql);

# ------------------------------------------------------------
# Iterate through files
# ------------------------------------------------------------

sub wanted
{
    my $complete_filename = $_;

    warn "Examining file: '$complete_filename'\n";

    # $File::Find::dir is current directory name
    # $_ is current filename
    # $File::Find::name is the complete pathname to the file

    # Give the model the same name as the file
    $dbh->begin_work();

    if ($complete_filename =~ /(.+).nlogo$/)
    {
        my $model_name = $1;

        warn "\tAdding '$model_name'\n";

        eval {
            # Insert the new model node
            $insert_model_node_sth->execute($model_name);
            my $node_id = $dbh->last_insert_id(undef, undef, 'nodes', 'id');

            my $contents;

            if (open FILE, $complete_filename)
            {
                local $/ = undef;
                $contents = <FILE>;
            }
            else
            {
                warn "\tCannot open '$complete_filename': $! ";
                $dbh->rollback();
                return;
            }

            # Insert the first version of this new model node
            $insert_node_version_sth->execute($node_id, $contents, $model_name);

            # Is there a preview image in the same directory?  If so,
            # then let's create a new preview node -- whose parent is
            # the new model node -- and a version for that
            my $preview_filename = $complete_filename;
            $preview_filename =~ s/.nlogo/.png/;

            my $preview_contents;
            if (-e $preview_filename and -f $preview_filename)
            {
                warn "\t\tFound a preview image for this model: '$preview_filename'.\n";

                if (open FILE, $preview_filename)
                {
                    warn "\t\t\tLoading preview file contents...";
                    local $/ = undef;
                    $preview_contents = <FILE>;
                    warn "done.\n";
                }
                else
                {
                    warn "\tCannot open '$complete_filename': $! ";
                    $dbh->rollback();
                    return;
                }

                warn "\t\tInserting preview node...\n";
                $insert_preview_node_sth->execute($node_id, "$model_name.png");
                my $preview_node_id = $dbh->last_insert_id(undef, undef, 'nodes', 'id');

                warn "\t\tInserting preview node version...\n";
                $insert_node_version_sth->execute($preview_node_id,
                                                  $preview_contents,
                                                  "$model_name preview");
            }
            else
            {
                warn "\t\tNo preview image found.\n";
            }

            $dbh->commit();
            warn "\t\tDone.\n";
        };

        # If there was an error inserting this node, catch and report it
        if ($@)
        {
            warn $@;
            warn "\t\tIgnoring this model, due to DBI problems.\n";
            $dbh->rollback();
            return;
        }
    }

    else
    {
        warn "\tNot a .nlogo file: Ignoring.\n";
        $dbh->rollback();
        return;
    }
}

# Search!
find(\&wanted, @directories_to_search);

$insert_model_node_sth->finish();
$insert_node_version_sth->finish();

$dbh->disconnect();
