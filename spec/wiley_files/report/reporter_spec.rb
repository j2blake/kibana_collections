require_relative '../../spec_helper'
require_relative '../../../lib/wiley_files/report/report'

RSpec::Matchers.define_negated_matcher :not_include, :include

describe WileyFiles::Report::Reporter do
  before(:each) do
    @r = WileyFiles::Report::Reporter.new()
  end

  context "when simple reporting" do

    it 'reports a simple string' do
      expect {
        @r.report("Hi")
      }.to output(include("Hi")).to_stdout
    end

    it 'includes a timestamp' do
      expect {
        @r.report("Hi")
      }.to output(match(/^\d\d:\d\d:\d\d\.\d\d\d\s/)).to_stdout
    end

    it 'formats arguments' do
      expect {
        @r.report("Hi, %{world}", world: "World")
      }.to output(include("Hi, World")).to_stdout
    end

    it 'stores templates' do
      expect {
        @r.set_template(:simple, "A %{template_level} template")
        @r.report(:simple, template_level: "simple")
      }.to output(include("A simple template")).to_stdout
    end

    it 'produces the expected message' do
      expect {
        @r.set_template(:hello, "Hello, %{who}")
        @r.report(:hello, who: "World")
      }.to output(match(/\A\d\d:\d\d:\d\d\.\d\d\d Hello, World\n\z/)).to_stdout
    end
  end

  context 'when options are used' do
    def with_options(options)
      yield WileyFiles::Report::Reporter.new(options)
    end

    it 'can show totals' do
      expect {
        with_options(with_totals: true) do |r|
          r.set_template(:template_name, "Try this.")
          r.report(:template_name)
          r.report(:template_name)
          r.close
        end
      }.to output(include("Total template_name: 2").and include("Try this")).to_stdout
    end

    it 'can show only totals' do
      expect {
        with_options(with_totals: true, with_details: false) do |r|
          r.set_template(:template_name, "Try this.")
          r.report(:template_name)
          r.report(:template_name)
          r.close
        end
      }.to output(include("Total template_name: 2").and not_include("Try this")).to_stdout
    end

    it 'can run silent' do
      expect {
        with_options(silent: true) do |r|
          r.set_template(:template_name, "Try this.")
          r.report(:template_name)
          r.report(:template_name)
          r.close
        end
      }.to_not output.to_stdout
    end
  end

  context 'with and without prefixes' do
    def with_prefixes(options = {})
      r = WileyFiles::Report::Reporter.new(options)
      r.with_prefix("p1") do |p1|
        p1.with_prefix("p2") do |p2|
          r.set_template(:t0, "Zero")
          p1.set_template(:t1, "One")
          p2.set_template(:t2, "Two")
          yield r, p1, p2
        end
      end
    end

    it 'includes one or more prefixes in the report' do
      expect {
        with_prefixes do |r, p1, p2|
          r.report(:t0)
          p1.report(:t1)
          p2.report(:t2)
        end
      }.to output(match(/.* Zero.* p1 One.* p1 p2 Two.* p1 p2 .* p1/m)).to_stdout
    end

    it 'includes the prefixes in the totals' do
      expect {
        with_prefixes(with_details: false, with_totals: true) do |r, p1, p2|
          r.report(:t0)
          p1.report(:t1)
          p2.report(:t2)
        end
      }.to output(match(/.* p1 p2 Total t2: 1.* p1 Total t1: 1/m)).to_stdout
    end

    it 'can use templates from the parent' do
      expect {
        with_prefixes() do |r, p1, p2|
          p1.report(:t0)
          p2.report(:t0)
          p2.report(:t1)
        end
      }.to output(match(/p1 Zero.* p1 p2 Zero.* p1 p2 One/m)).to_stdout
    end

    it 'holds its own options' do
      expect {
        r = WileyFiles::Report::Reporter.new(silent: true)
        r.with_prefix("p1", with_details: true) do |p|
          p.report("See me")
        end
        r.report("Don't see me")
      }.to output(include("See me").and not_include("Don't see me")).to_stdout
    end
  end

  context 'when limiting' do
    it 'works on a reporter' do
      expect {
        r = WileyFiles::Report::Reporter.new(limit: 2)
        r.report("X")
        r.report("X")
        r.report("X")
        r.close
      }.to output(match(/X.* X[^X]* more: X/m)).to_stdout
    end

    it 'works on a sub-reporter' do
      expect {
        r = WileyFiles::Report::Reporter.new
        r.reporter(limit: 2) do |sub|
          sub.report("X")
          sub.report("X")
          sub.report("X")
        end
      }.to output(match(/X.* X[^X]* more: X/m)).to_stdout
    end

    it 'works on a prefixer' do
      expect {
        r = WileyFiles::Report::Reporter.new
        r.with_prefix("p1", limit: 2) do |p|
          p.report("X")
          p.report("X")
          p.report("X")
        end
      }.to output(match(/p1 X.* p1 X[^X]* p1.* more: X/m)).to_stdout
    end

    it 'works above a prefixer' do
      expect {
        r = WileyFiles::Report::Reporter.new(limit: 2)
        r.with_prefix("p1") do |p|
          p.report("X")
          p.report("X")
          p.report("X")
        end
      }.to output(match(/p1 X.* p1 X[^X]* p1.* more: X/m)).to_stdout
    end
  end
end
