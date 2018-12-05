#!/usr/bin/env ruby

=begin
--------------------------------------------------------------------------------

Run through the JR1, JR5, and pricing files for overview and stats

--------------------------------------------------------------------------------
=end

$: << File.expand_path("../../../lib", __FILE__)

require 'pp'

require 'populate/hashPath'

require 'wiley_files/analyzer'
require 'wiley_files/analyze_jr1_and_jr5'
require 'wiley_files/flattener'
require 'wiley_files/report/reporter'
require 'wiley_files/report/limiting_reporter'
require 'wiley_files/report/mute_reporter'
require 'wiley_files/report/prefixed_reporter'
require 'wiley_files/scan/scanner'
require 'wiley_files/scan/jr_scanner'
require 'wiley_files/scan/jr1_scanner'
require 'wiley_files/scan/jr5_scanner'
require 'wiley_files/scan/price_list_e_scanner'

WileyFiles::Analyzer.new(ARGV[0]).run
