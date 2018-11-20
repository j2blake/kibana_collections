#!/usr/bin/env ruby

=begin
--------------------------------------------------------------------------------

Populate a flat index with the contents of a file, named on the command line.

--------------------------------------------------------------------------------
=end

$: << File.expand_path("../../../lib", __FILE__)
require 'populate/populator'
require 'tf_sk_output/flat_populator'

TF_SK_Output::FlatPopulator.new.run
