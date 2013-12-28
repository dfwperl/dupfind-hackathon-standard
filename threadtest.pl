#!/usr/bin/env perl

=pod

=head1 PROOF THAT MULTILEVEL DATASTRUCTURES CAN BE SHARED BETWEEN THREADS

Yes.  Yes they can.  It's just tricky.

This is proof-of-concept code that has nothing to do with finding duplicate
files like dupfind does.  This is not the code you're looking for.

=cut

use 5.010;

use warnings;
use strict;

use threads;
use threads::shared;
use Thread::Queue;
use Data::Dumper;

use vars qw( $hashref $term $pool $poolq $threads $tasks );

$hashref = &share( {} );
$term    = 0; share $term;
$pool    = {};
$poolq   = Thread::Queue->new();
$threads = 20;
$tasks   = 100;

$SIG{TERM} = $SIG{INT} = \&end_pool;

sub end_pool
{
   $term++;

   $pool->{ $_ }->end for keys %$pool;

   $poolq->end;

   $_->join for threads->list;

   say Dumper $hashref;

   say 'All threads joined';
};

# Create the thread pool

for ( 1 .. $threads )
{
  # Create a work queue for a thread
  my $tqueue = Thread::Queue->new();

  # Create the thread, and give it the work queue
  my $thread = threads->create( worker => $tqueue );

  # Remember the thread's work queue
  $pool->{ $thread->tid } = $tqueue;
}

# give work to the threads

for ( 1 .. $tasks )
{
   my $tid = $poolq->dequeue;

   last unless defined $tid;

   $pool->{ $tid }->enqueue( $_ ) if !$term;
}

end_pool();

exit;

sub worker
{
   my $tqueue = shift;

   my $tid = threads->tid;

   while ( !$term )
   {
      say "Thread $tid is idle";

      # signal to the thread poolq that we are ready to work
      $poolq->enqueue( $tid );

      # wait for some work to be put into my queue
      my $work = $tqueue->dequeue;

      last unless defined $work;

      say "Thread $tid just got a job: $work";

      my $arrayref    = &share( [] );
      my $shared_href = &share( {} );
      my $rand_key    = int rand 10;

      sleep int rand 3;

      lock $hashref;

      $hashref->{ $rand_key } ||= $arrayref;

      $shared_href->{ $rand_key } = $work;

      push @{ $hashref->{ $rand_key } }, $shared_href;

      say "Thread $tid is done with: $work";
   }
}

