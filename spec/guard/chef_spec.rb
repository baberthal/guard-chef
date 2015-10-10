require 'spec_helper'
require 'guard/compat/test/helper'

RSpec.describe Guard::Chef do
  let(:default_options) { Guard::Chef::Options::DEFAULTS }
  let(:options) { {} }
  let(:plugin) { Guard::Chef.new(options) }
  let(:runner) { instance_double(Guard::Chef::Runner) }

  before do
    allow(Guard::Compat::UI).to receive(:info)
    allow(Guard::Chef::Runner).to receive(:new) { runner }
  end

  it 'has a version number' do
    expect(Guard::ChefVersion::VERSION).not_to be nil
  end

  describe '.initialize' do
    it 'instanciates with default and custom options' do
      guard_chef = Guard::Chef.new(foo: :bar)
      expect(guard_chef.options).to eq(default_options.merge(foo: :bar))
    end

    it 'instanciates Runner with all default and custom options' do
      expect(Guard::Chef::Runner).to receive(:new)
        .with(default_options.merge(foo: :bar))
      Guard::Chef.new(foo: :bar)
    end
  end

  describe '#start' do
    it 'doesnt call #run_all by default' do
      expect(plugin).to_not receive(:run_all)
      plugin.start
    end

    context 'with all_on_start: true' do
      let(:options) { { all_on_start: true } }
      it 'calls #run_all' do
        expect(plugin).to receive(:run_all)
        plugin.start
      end
    end
  end

  describe '#run_all' do
    it 'runs all specs via runner' do
      expect(runner).to receive(:run_all) { true }
      plugin.run_all
    end

    it 'throws :task_has_failed if runner returns false' do
      allow(runner).to receive(:run_all) { false }
      expect(plugin).to receive(:throw).with(:task_has_failed)
      plugin.run_all
    end
  end

  describe '#reload' do
    it 'reloads via the runner' do
      expect(runner).to receive(:reload)
      plugin.reload
    end
  end

  describe '#run_on_modifications' do
    let(:paths) { %w(path1 path2) }
    it 'runs all specs via runner' do
      expect(runner).to receive(:run).with(paths) { true }
      plugin.run_on_modifications(paths)
    end

    it 'does nothing if paths empty' do
      expect(runner).to_not receive(:run)
      plugin.run_on_modifications([])
    end

    it 'throws :task_has_failed if runner returns false' do
      allow(runner).to receive(:run) { false }
      expect(plugin).to receive(:throw).with(:task_has_failed)
      plugin.run_on_modifications(paths)
    end
  end
end
