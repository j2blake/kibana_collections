require_relative '../spec_helper'
require_relative '../../lib/populate/hashPath'

describe Populate::HashPath::HashPath do
  before(:each) do
    @sample = {
      a: 1,
      b: {
        bb: 2
      },
      p: [
        {
          pp: 3,
          pa: 4,
          pv: 5,
          pc: {
            pcc: 6
          }
        }
      ]
    }
    @clone_before = @sample.clone
  end

  describe '#==' do
    it 'is equal on a simple at' do
      expect({}.at(:a)).to eq({}.at(:a))
    end

    it 'is equal on a two-level at' do
      expect({}.at(:a, :b)).to eq({}.at(:a, :b))
    end

    it 'is equal on a pick' do
      expect({}.at(:a, [:b, :c, :value])).to eq({}.at(:a, [:b, :c, :value]))
    end

    it 'is equal beneath a pick' do
      expect({}.at(:a, [:b, :c, :value], :d)).to eq({}.at(:a, [:b, :c, :value], :d))
    end
  end

  describe 'path versus chain' do
    it 'accepts a second level' do
      expect(@sample.at(:b, :bb)).to eq(@sample.at(:b).at(:bb))
    end

    it 'accepts a pick' do
      expect(@sample.at(:p, [:pp, :pv, 3])).to eq(@sample.at(:p).pick(:pp, :pv, 3))
    end

    it 'accepts from beneath a pick' do
      expect(@sample.at(:p, [:pp, :pv, 3], :ppp)).to eq(@sample.at(:p).pick(:pp, :pv, 3).at(:ppp))
    end
  end

  describe '#get' do
    after(:each) do
      expect(@sample).to eq(@clone_before)
    end

    context 'when getting existing values' do
      it 'returns a top-level value' do
        expect(@sample.at(:a).get).to eq(1)
      end

      it 'returns a second-level value' do
        expect(@sample.at(:b, :bb).get).to eq(2)
      end

      it 'returns a value from a pick' do
        expect(@sample.at([:p, :pp, 3]).get).to eq({pp: 3, pa: 4, pv: 5, pc: {pcc: 6}})
      end

      it 'returns a value from beneath a pick' do
        expect(@sample.at([:p, :pp, 3], :pv).get).to eq(5)
      end

      it 'returns a value from well beneath a pick' do
        expect(@sample.at([:p, :pp, 3], :pc, :pcc).get).to eq(6)
      end
    end

    context 'when values are not found' do
      it 'no value at top-level' do
        expect(@sample.at(:z).get).to be_nil
      end

      it 'no value at second-level' do
        expect(@sample.at(:b, :z).get).to be_nil
      end

      it 'no value from a pick' do
        expect(@sample.at([:p, :pp, 99]).get).to be_nil
      end

      it 'no value from beneath a pick' do
        expect(@sample.at([:p, :pp, 3], :z).get).to be_nil
      end

      it 'no value from well beneath a pick' do
        expect(@sample.at([:p, :pp, 3], :pc, :z).get).to be_nil
      end
    end

    context 'when structures are not found' do
      it 'no structure at second-level' do
        expect(@sample.at(:z, :zz).get).to be_nil
      end

      it 'no structure from a pick' do
        expect(@sample.at([:p, :z, 99]).get).to be_nil
      end

      it 'no structure beneath a pick' do
        expect(@sample.at([:p, :pp, 3], :z).get).to be_nil
      end

      it 'no structure from well beneath a pick' do
        expect(@sample.at([:p, :pp, 3], :z, :zz).get).to be_nil
      end

      it 'no structures for several levels' do
        expect(@sample.at([:z, :zz, 3], :zzz, :zzzz).get).to be_nil
      end
    end
  end

  describe '#values' do
    it 'returns an empty result if the value is not an array' do
      expect({a: 3}.at(:a).values(:aa)).to eq([])
    end

    it 'returns the requested values' do
      expect({a: [{aa: 5}, {aa: 10, b: 99}]}.at(:a).values(:aa)).to eq([5, 10])
    end

    it 'ignores array members that are not hashes' do
      expect({a: [{aa: 5}, :b]}.at(:a).values(:aa)).to eq([5])
    end

    it 'ignores hashes where the selector is not present' do
      expect({a: [{z: 5}, {aa: 10, b: 99}]}.at(:a).values(:aa)).to eq([10])
    end
  end

  describe '#<<' do
    context 'when pushing a nil' do
      shared_examples_for 'it ignores nil values' do
        after(:each) do
          expect(@sample).to eq(@clone_before)
        end

        it 'ignores a nil at the top level' do
          @sample.at(:z) << nil_value
        end

        it 'ignores a nil at the second level' do
          @sample.at(:a, :z) << nil_value
        end

        it 'ignores a nil in a pick' do
          @sample.at([:p, :pp, 99]) << nil_value
        end

        it 'ignores a nil beneath a pick' do
          @sample.at([:p, :pp, 3], :z) << nil_value
        end

        it 'ignores a nil well beneath a pick' do
          @sample.at([:p, :pp, 3], :pc, :z) << nil_value
        end
      end

      describe 'ignore an actual nil' do
        it_should_behave_like 'it ignores nil values' do
          let(:nil_value) { nil }
        end
      end

      describe 'ignore a path with a nil value' do
        it_should_behave_like 'it ignores nil values' do
          let(:nil_value) { {}.at(:nothing) }
        end
      end
    end

    context 'when adding to existing values' do
      it 'adds at the top level' do
        actual = {a: 1}.at(:a) << 2
        expected = {a: [1, 2]}
        expect(actual).to eq(expected)
      end

      it 'adds at the second level' do
        actual = {a: {aa: 1}}.at(:a, :aa) << 2
        expected = {a: {aa: [1, 2]}}
        expect(actual).to eq(expected)
      end

      it 'adds beneath a pick' do
        actual = {p: [{pp: 3, pv: 1}]}.at([:p, :pp, 3], :pv) << 2
        expected = {p: [{pp: 3, pv: [1, 2]}]}
        expect(actual).to eq(expected)
      end

      it 'adds well beneath a pick' do
        actual = {p: [{pp: 3, pv: {a: 1}}]}.at([:p, :pp, 3], :pv, :a) << 2
        expected = {p: [{pp: 3, pv: {a: [1, 2]}}]}
        expect(actual).to eq(expected)
      end
    end

    context 'when adding to existing structures' do
      it 'adds at the top level' do
        actual = {a: 1}.at(:b) << 2
        expected = {a: 1, b: 2}
        expect(actual).to eq(expected)
      end

      it 'adds at the second level' do
        actual = {a: {aa: 1}}.at(:a, :ab) << 2
        expected = {a: {aa: 1, ab: 2}}
        expect(actual).to eq(expected)
      end

      it 'adds beneath a pick' do
        actual = {p: [{pp: 3, a: 1}]}.at([:p, :pp, 3], :b) << 2
        expected = {p: [{pp: 3, a: 1, b: 2}]}
        expect(actual).to eq(expected)
      end

      it 'adds well beneath a pick' do
        actual = {p: [{pp: 3, a: {aa: 1}}]}.at([:p, :pp, 3], :a, :ab) << 2
        expected = {p: [{pp: 3, a: {aa: 1, ab: 2}}]}
        expect(actual).to eq(expected)
      end
    end

    context 'when adding to new structures' do
      it 'adds at the top level' do
        actual = {}.at(:a) << 1
        expected = {a: 1}
        expect(actual).to eq(expected)
      end

      it 'adds at the second level' do
        actual = {}.at(:a, :aa) << 1
        expected = {a: {aa: 1}}
        expect(actual).to eq(expected)
      end

      it 'adds beneath a pick' do
        actual = {}.at([:p, :pp, 3], :a) << 1
        expected = {p: [{pp: 3, a: 1}]}
        expect(actual).to eq(expected)
      end

      it 'adds well beneath a pick' do
        actual = {}.at([:p, :pp, 3], :a, :aa) << 1
        expected = {p: [{pp: 3, a: {aa: 1}}]}
        expect(actual).to eq(expected)
      end
    end
  end
end