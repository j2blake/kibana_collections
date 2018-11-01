#!/usr/bin/env ruby

=begin
--------------------------------------------------------------------------------

Populate a flat index (with timestamps for years) with the contents of a file, named on the command line.

--------------------------------------------------------------------------------
=end

$: << File.expand_path("../../lib", __FILE__)
require 'populate/populator'
require 'populate/stamped_populator'

Populate::StampedPopulator.new.run
