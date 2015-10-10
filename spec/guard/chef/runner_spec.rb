require 'guard/compat/test/helper'
require 'launchy'
require 'guard/chef/runner'

RSpec.describe Guard::Chef::Runner do
  let(:options) { { cmd: 'rspec' } }
  let(:runner) { Guard::Chef::Runner.new(options) }
  let(:inspector) { instance_double(Guard::Chef::Inspectors::SimpleInspector) }
  let(:notifier) { instance_double(Guard::Chef::Notifier) }
  let(:results) { instance_double(Guard::Chef::Results) }
  let(:process) { instance_double(Guard::Chef::RSpecProcess) }

  before do
    allow(Guard::Compat::UI).to receive(:info)
    allow(Guard::Compat::UI).to receive(:error)
    allow(Guard::Chef::Inspectors::Factory).to receive(:create) { inspector }
    allow(Guard::Chef::Notifier).to receive(:new) { notifier }
    allow(Guard::Chef::Command).to receive(:new) { 'rspec' }
    allow(notifier).to receive(:notify)
    allow(notifier).to receive(:notify_failure)

    allow(results).to receive(:summary).and_return('Summary')
    allow(results).to receive(:failed_paths).and_return([])

    allow(Guard::Chef::RSpecProcess).to receive(:new).and_return(process)
    allow(process).to receive(:all_green?).and_return(true)
    allow(process).to receive(:results).and_return(results)
  end

  describe '.initialize' do
    context 'with custom options' do
      let(:options) { { foo: :bar } }

      it 'instanciates inspector via Inspectors::Factory with custom opts ' do
        expect(Guard::Chef::Inspectors::Factory)
          .to receive(:create).with(foo: :bar)
        runner
      end

      it 'instanciates notifier with custom opts' do
        expect(Guard::Chef::Notifier).to receive(:new).with(foo: :bar)
        runner
      end
    end
  end

  describe '#reload' do
    it 'calls inspector\'s #reload' do
      expect(inspector).to receive(:reload)
      runner.reload
    end
  end

  shared_examples 'abort' do
    it 'aborts' do
      expect(Guard::Compat::UI).to_not receive(:info)
      subject
    end

    it 'returns true' do
      expect(subject).to be true
    end
  end

  describe '#run_all' do
    let(:options) do
      {
        spec_paths: %w(spec1 spec2),
        cmd: 'rspec',
        run_all: { message: 'Custom Message' }
      }
    end

    before do
      allow(inspector).to receive(:failed)
    end

    it 'builds commands with spec paths' do
      expect(Guard::Chef::Command).to receive(:new)
        .with(%w(spec1 spec2), kind_of(Hash))
      runner.run_all
    end

    it 'prints message' do
      expect(Guard::Compat::UI).to receive(:info)
        .with('Custom Message', reset: true)
      runner.run_all
    end

    context 'when no paths are given' do
      subject { runner.run_all }
      let(:options) do
        {
          spec_paths: [],
          run_all: { message: 'Custom Message' }
        }
      end
      include_examples 'abort'
    end

    context 'with custom cmd' do
      before { options[:run_all][:cmd] = 'rspec -t ~slow' }

      it 'bulds command with custom cmd' do
        expect(Guard::Chef::Command).to receive(:new)
          .with(kind_of(Array), hash_including(cmd: 'rspec -t ~slow'))
        runner.run_all
      end
    end

    context 'with no cmd' do
      before do
        options[:cmd] = nil
        allow(Guard::Chef::Command).to receive(:new)
        allow(Guard::Compat::UI).to receive(:error).with(an_instance_of(String))
        allow(notifier).to receive(:notify_failure)
        runner.run_all
      end

      it 'does not build' do
        expect(Guard::Chef::Command).to_not have_received(:new)
      end

      it 'issues a warning to the user' do
        expect(Guard::Compat::UI).to have_received(:error)
          .with(an_instance_of(String))
      end

      it 'notifies the notifier of failure' do
        expect(notifier).to have_received(:notify_failure)
      end
    end

    describe 'return value' do
      subject { runner.run_all }
      it { is_expected.to be true }

      context 'when process is not all green' do
        before { allow(process).to receive(:all_green?).and_return(false) }
        it { is_expected.to be false }
      end
    end
  end

  describe '#run' do
    let(:paths) { %w(spec_path1 spec_path2) }
    before do
      allow(inspector).to receive(:paths) { paths }
      allow(inspector).to receive(:failed)
    end

    it 'prints running message' do
      expect(Guard::Compat::UI).to receive(:info)
        .with("Running: spec_path1 spec_path2", reset: true)
      runner.run(paths)
    end

    context 'when no paths are given' do
      subject { runner.run([]) }
      before { allow(inspector).to receive(:paths) { [] } }
      include_examples 'abort'
    end

    it 'builds commands with spec paths' do
      expect(Guard::Chef::Command).to receive(:new)
        .with(%w(spec_path1 spec_path2), kind_of(Hash))
      runner.run(paths)
    end

    context 'with all_after_pass option' do
      let(:options) { { cmd: 'rspec', all_after_pass: true } }
      it 're-runs all if run is successful' do
        expect(runner).to receive(:run_all)
        runner.run(paths)
      end
    end

    context 'with launchy options' do
      let(:options) { { cmd: 'rspec', launchy: 'launchy_path'} }
      before do
        allow(Pathname).to receive(:new)
          .with('launchy_path') { double(exist?: true) }
      end

      it 'opens Launchy' do
        expect(Launchy).to receive(:open).with('launchy_path')
        runner.run(paths)
      end
    end

    context 'with a custom results file' do
      let(:options) do
        { cmd: 'rspec', results_file: results_file }.merge(chdir_options)
      end

      context 'with no chdir option' do
        let(:chdir_options) { {} }

        context 'when the path is relative' do
          let(:results_file) { 'foobar.txt' }
          it 'uses the given file' do
            expect(Guard::Chef::RSpecProcess).to receive(:new)
              .with(anything, results_file).and_return(process)
            runner.run(paths)
          end
        end

        context 'when the path is absolute' do
          let(:results_file) { '/foo/foobar.txt' }
          it 'uses the given file' do
            expect(Guard::Chef::RSpecProcess).to receive(:new)
              .with(anything, results_file).and_return(process)
            runner.run(paths)
          end
        end
      end

      context 'with chdir option' do
        let(:chdir_options) { { chdir: 'moduleA' } }

        context 'when the path is relative' do
          let(:results_file) { 'foobar.txt' }

          it 'uses a path relative to chdir' do
            expect(Guard::Chef::RSpecProcess).to receive(:new)
              .with(anything, 'moduleA/foobar.txt').and_return(process)
            runner.run(paths)
          end
        end

        context 'when the path is absolute' do
          let(:results_file) { '/foo/foobar.txt' }
          it 'uses the full given path anyway' do
            expect(Guard::Chef::RSpecProcess).to receive(:new)
              .with(anything, results_file).and_return(process)
            runner.run(paths)
          end
        end
      end
    end

    context 'with no custom results file' do
      let(:options) { { cmd: 'rspec' } }
      it 'uses the default' do
        expect(Guard::Chef::RSpecProcess).to receive(:new)
          .with(anything, 'tmp/chef_guard_result').and_return(process)
        runner.run(paths)
      end
    end

    it 'notifies inspector about failed paths' do
      expect(inspector).to receive(:failed).with([])
      runner.run(paths)
    end

    context 'with failed paths' do
      before do
        allow(results).to receive(:failed_paths).and_return([
          './failed_spec.rb:123',
          './other/failed_spec.rb:77'
        ])
      end

      it 'notifies the inspector about failed paths' do
        expect(inspector).to receive(:failed).with([
          './failed_spec.rb:123',
          './other/failed_spec.rb:77'
        ])
        runner.run(paths)
      end
    end

    it 'notifies success' do
      expect(notifier).to receive(:notify).with('Summary')
      runner.run(paths)
    end

    it 'notifies failure' do
      allow(process).to receive(:all_green?)
        .and_raise(Guard::Chef::RSpecProcess::Failure, /Failed: /)
      expect(notifier).to receive(:notify_failure)
      runner.run(paths)
    end

    describe 'return value' do
      subject { runner.run(paths) }
      it { is_expected.to be true }

      context 'with all_after_pass: true' do
        let(:options) do
          { cmd: 'rspec', all_after_pass: true, run_all: {}, spec_paths: paths }
        end

        it { is_expected.to be true }

        describe 'when all tests fail' do
          before do
            allow(process).to receive(:all_green?).and_return(true, false)
          end

          it { is_expected.to be false }
        end
      end

      context 'when process is not all green' do
        before { allow(process).to receive(:all_green?).and_return(false) }

        it { is_expected.to be false }
      end
    end
  end
end
