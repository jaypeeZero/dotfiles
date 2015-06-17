#!/usr/bin/perl
use strict;
use warnings;

use File::Find;
use File::stat;
use Digest::MD5;
use Fcntl;
use Cwd 'abs_path';


my $progname = $0;
$progname =~ s@.*/@@g;

unless (scalar(@ARGV) > 0) {
print <<"USAGE";

Usage: $progname dir1 [dir2] ... [dirN] [-d] [-dt] [-same] [-all]

Scans dir1 for duplicates of any file found under dir1 to dirN. Also
finds truncated copies of files, provided that at least the first 32K
of each copy is intact. Also reports whether files are "similar", which
means that 32K or more matched before a difference was found.

Switches:
    -d: Delete duplicates found under dir1
    -dt: Delete truncated dupes found anywhere (not just dir1)
    -same: Only compares files which have the same name.
    -all: Treat all directories as if they're dir1. -d will delete
        files found under any directory.

Suggestion: do trial runs without -d / -dt first. Dupes and truncations
printed in the left hand column are what will be deleted by -d or -dt.

USAGE
exit;
}

# parse command line arguments
my @searchDirs;
my $deleteDupeMode = 0;
my $deleteTruncMode = 0;
my $sameNameMode = 0;
my $allMode = 0;

foreach my $arg (@ARGV) {
    if ($arg eq "-d") {
        $deleteDupeMode = 1;
    } elsif ($arg eq "-dt") {
        $deleteTruncMode = 1;
    } elsif ($arg eq "-same") {
        $sameNameMode = 1;
    } elsif ($arg eq "-all") {
        $allMode = 1;
    } else {
        if (-d $arg) {
            push (@searchDirs, $arg) 
        } else {
            die "Error: \"$arg\" is not a directory.\n";
        }
    }
}

# Hash of fileInfo containing all files under examination.
# Keyed by absolute pathname to guarantee we don't examine the same file twice.
my %filesByAbsPath;

# Hash of arrays of fileInfo.  Keyed by MD5 tag; identifies lists of files which
# should be compared to one another.
my %filesByTag;

# Global to track whether files currently being added are in the first pass
my $first = 1;


# calcTag: returns the MD5 digest of the first 32K of the given file (its 'tag')
sub calcTag($)
{
    my ($filename) = @_;

    if (-d $filename) {
        # doing MD5 on a directory is not supported
        return "unsupported"; # we need to return something
    }

    # Use 'sysopen' to safely handle filenames with leading
    # whitespace or leading "-"
    sysopen(FILE, $filename, O_RDONLY)
         or die "Unable to open file \"$filename\": $!\n";
    binmode(FILE); # just in case we're on Windows!
    my $data;
    read(FILE, $data, 32768);
    close(FILE);
    return Digest::MD5->new->add($data)->hexdigest;
}


# checkFile: invoked from the 'find' routine on each file or directory in turn
sub checkFile()
{
    return unless -f $_; # only interested in files, not directories

    my $filename = $_;
    my $dirname = $File::Find::dir;
    my $path = $File::Find::name;

    return if $filename =~ /^\._/; # ignore files whose names start with "._"
    return if $filename =~ /^\.DS_Store$/;

    # Never examine the same file twice.  Avoids detecting the
    # same file as a dupe of itself when the user invokes the
    # script on nested directories.
    my $abspath = abs_path($filename);
    return if ($filesByAbsPath{$abspath});

    my $statInfo = stat($filename)
        or warn "Can't stat file \"$dirname/$filename\": $!\n" and return;
    my $size = $statInfo->size;
    my $tag = calcTag("$filename");

    my $fileInfo = {
        'name' => $filename,
        'path' => $path,
        'size' => $size,
        'first' => $first,
    };

    $filesByAbsPath{$abspath} = $fileInfo;
    push(@{$filesByTag{$tag}}, $fileInfo);
}


use constant SIZE => 131072;

sub compareFiles
{
    my $finf1 = shift;
    my $finf2 = shift;
    
    my $fn1 = $finf1->{path};
    my $fn2 = $finf2->{path};
    
    if ($sameNameMode && $finf1->{name} ne $finf2->{name}) {
        return;
    }

    sysopen(FILE1, $fn1, O_RDONLY)
         or die "Unable to open file \"$fn1\": $!\n";
    binmode(FILE1); # just in case we're on Windows!

    sysopen(FILE2, $fn2, O_RDONLY)
         or die "Unable to open file \"$fn2\": $!\n";
    binmode(FILE2); # just in case we're on Windows!

    my ($data1, $data2);
    my ($nbytes1, $nbytes2);
    my $bytes_compared = 0;
    my $same = 1;
    my $trunc = 0;

    do {
        $nbytes1 = read(FILE1, $data1, SIZE);
        $nbytes2 = read(FILE2, $data2, SIZE);

        my $len = ($nbytes1 < $nbytes2) ? $nbytes1 : $nbytes2;
        $bytes_compared += $len;

        if ($data1 ne $data2) {
            $same = 0;
            if ($nbytes1 != $nbytes2) {
                my $tdata1 = substr($data1, 0, $len);
                my $tdata2 = substr($data2, 0, $len);
                $trunc = 1 if ($tdata1 eq $tdata2);
            }
        }
    } while ($nbytes1 == SIZE && $nbytes2 == SIZE);
    
    close(FILE1);
    close(FILE2);

    if ($same) {
        push(@{$finf1->{dupe}}, $finf2);
    } elsif ($trunc) {
        if ($finf1->{size} < $finf2->{size}) {
            push(@{$finf1->{trunc}}, $finf2);
        } else {
            push(@{$finf2->{trunc}}, $finf1);
        }
    } else {
        push(@{$finf1->{sim}}, $finf2);
    }
}


MAIN:
{
    # Calculate MD5 hash tags for all files.
    while (my $dir = shift @searchDirs) {
        print "Hashing files under \"$dir\" ...\n";
        find(\&checkFile, $dir);
        $first = 0;
    }

    # Check for duplicate, truncated, and similar files based on the MD5 hash tag.
    foreach my $fileList (values %filesByTag) {
        while (my $finfo1 = shift @{$fileList}) {
            if ($allMode || $finfo1->{first}) {
                foreach my $finfo2 (@{$fileList}) {
                    compareFiles($finfo1, $finfo2);
                }
            }
        }
    }

    # Find the maximum path name length to prettify printout
    my $maxlen = 0;
    foreach my $finfo (values %filesByAbsPath) {
        if ($finfo->{dupe} || $finfo->{trunc} || $finfo->{sim}) {
            my $len = length($finfo->{path});
            $maxlen = ($maxlen > $len) ? $maxlen : $len;
        }
    }
    $maxlen += 1;

    # Print information about each dupe/trunc/similar and optionally delete
    foreach my $finfo (sort values %filesByAbsPath) {
        # only want to print the original name once, for clarity,
        # so store it in a string and clear the string after each use
        my $name = $finfo->{path};
        foreach my $dupe (@{$finfo->{dupe}}) {
            printf("%-${maxlen}s DUPE OF     %s\n", $name, $dupe->{path});
            $name = "";
        }

        foreach my $trunc (@{$finfo->{trunc}}) {
            printf("%-${maxlen}s TRUNC OF    %s\n", $name, $trunc->{path});
            $name = "";
        }

        foreach my $sim (@{$finfo->{sim}}) {
            printf("%-${maxlen}s similar to  %s\n", $name, $sim->{path});
            $name = "";
        }
        
        if (($finfo->{dupe} && $deleteDupeMode) || ($finfo->{trunc} && $deleteTruncMode)) {
            if (unlink $finfo->{path}) {
                printf("%-${maxlen}s DELETED\n", $finfo->{path});
            } else {
                warn "Couldn't delete $finfo->{path}\n";
            }
        }
    }
}