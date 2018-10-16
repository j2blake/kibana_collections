#!/usr/bin/env ruby

=begin
--------------------------------------------------------------------------------

Populate the index with the contents of a file, named on the command line.

--------------------------------------------------------------------------------
=end

$: << File.expand_path("../../lib", __FILE__)
require 'populate/populator'
require 'populate/nested_populator'

Populate::NestedPopulator.new.run
