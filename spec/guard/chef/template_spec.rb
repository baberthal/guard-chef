require 'guard/compat/test/template'
require 'guard/chef'

RSpec.describe Guard::Chef do
  describe 'template' do
    subject { Guard::Compat::Test::Template.new(described_class) }

    it 'matches spec files by default' do
      expect(subject.changed('spec/unit/recipes/default_spec.rb'))
        .to eq(%w(spec/unit/recipes/default_spec.rb))

      expect(subject.changed('spec/spec_helper.rb')).to eq(%w(spec))
    end

    describe 'mapping files to specs' do
      before do
        allow(Dir).to receive(:exist?).with('spec/lib').and_return(has_spec_lib)
      end

      context 'when spec/lib exists' do
        let(:has_spec_lib) { true }
        it 'matches Ruby files with files in spec/lib' do
          expect(subject.changed('lib/foo.rb')).to eq(%w(spec/lib/foo_spec.rb))
        end
      end

      context 'when spec/lib does not exist' do
        let(:has_spec_lib) { false }
        it 'matches Ruby files with files in spec/' do
          expect(subject.changed('lib/foo.rb')).to eq(%w(spec/foo_spec.rb))
        end
      end
    end

    describe 'matching cookbook files' do
      it 'matches recipe files by default' do
        expect(subject.changed('recipes/default.rb'))
          .to eq(%w(spec/unit/recipes/default_spec.rb))
      end

      it 'matches attributes to the recipe files' do
        expect(subject.changed('attributes/default.rb'))
          .to eq(%w(spec/unit/recipes/default_spec.rb))
      end

      it 'matches library files by default' do
        expect(subject.changed('libraries/my_lib.rb'))
          .to eq(%w(spec/unit/libraries/my_lib_spec.rb))
      end
    end
  end
end
