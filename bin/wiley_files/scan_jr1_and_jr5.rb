#!/usr/bin/env ruby

=begin
--------------------------------------------------------------------------------

Run through the JR1 and JR5 files for overview and stats

--------------------------------------------------------------------------------
=end

$: << File.expand_path("../../../lib", __FILE__)
require 'wiley_files/report/reporter'
require 'wiley_files/report/prefixed_reporter'
require 'wiley_files/scan/scanner'
require 'wiley_files/jr1_and_jr5_scanner'

WileyFiles::Jr1AndJr5Scanner.new(ARGV[0]).run
