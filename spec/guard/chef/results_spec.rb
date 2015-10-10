require 'guard/compat/test/helper'
require 'guard/chef/results'

RSpec.describe Guard::Chef::Results do
  subject { described_class.new('foo/bar.txt') }
  before { allow(File).to receive(:readlines).with('foo/bar.txt') { data } }

  context 'with valid data' do
    let(:data) do
      [
        "5 examples, 2 failures (3 pending)\n",
        "foo1/bar1_spec.rb\n",
        "foo1/bar2_spec.rb\n"
      ]
    end

    describe '#summary' do
      it 'sets a summary' do
        expect(subject.summary).to eq '5 examples, 2 failures (3 pending)'
      end
    end

    describe '#failures' do
      it 'sets a list of failures' do
        expect(subject.failed_paths)
          .to eq(%w(foo1/bar1_spec.rb foo1/bar2_spec.rb))
      end
    end
  end

  context 'with no data' do
    let(:data) { [] }

    it 'crashes' do
      expect { subject.load }.to raise_error(
        Guard::Chef::Results::InvalidData,
        "Invalid results in: foo/bar.txt, lines:\n[]\n")
    end
  end

  context 'with invalid data' do
    let(:data) { [''] }

    it 'crashes' do
      expect { subject.load }.to raise_error(
        Guard::Chef::Results::InvalidData,
        "Invalid results in: foo/bar.txt, lines:\n[\"\"]\n")
    end
  end
end
