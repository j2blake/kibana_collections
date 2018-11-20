#!/usr/bin/env ruby

=begin
--------------------------------------------------------------------------------

Populate the index with the contents of a file, named on the command line.

--------------------------------------------------------------------------------
=end

$: << File.expand_path("../../../lib", __FILE__)
require 'populate/populator'
require 'tf_sk_output/nested_populator'

TF_SK_Output::NestedPopulator.new.run
