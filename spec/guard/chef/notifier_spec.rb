require 'guard/compat/test/helper'
require 'guard/chef/notifier'
require 'spec_helper'

RSpec.describe Guard::Chef::Notifier do
  let(:options) { { notification: true, title: 'RSpec results' } }
  let(:notifier) { Guard::Chef::Notifier.new(options) }

  # rubocop:disable OptionalArguments
  def expect_notification(title = 'RSpec results', message, image, priority)
    expect(Guard::Compat::UI).to receive(:notify)
      .with(message, title: title, image: image, priority: priority)
  end

  describe '#notify_failure' do
    it 'notifies about failure' do
      expect_notification('Failed', :failed, 2)
      notifier.notify_failure
    end

    context 'with a custom title' do
      let(:options) { { notification: true, title: 'Failure title' } }

      it 'notifies with the custom title' do
        expect_notification('Failure title', 'Failed', :failed, 2)
        notifier.notify_failure
      end
    end
  end

  describe '#notify' do
    it 'notifies about success' do
      expect_notification('This is summary', :success, -2)
      notifier.notify('This is summary')
    end

    context 'with pending examples' do
      let(:summary) { '5 examples, 0 failures (1 pending) in 4.0000 seconds' }

      it 'notifies about pending examples' do
        expect_notification(summary, :pending, -1)
        notifier.notify(summary)
      end
    end

    context 'with failures' do
      let(:summary) { '5 examples, 1 failures in 4.0000 seconds' }

      it 'notifies about failure' do
        expect_notification(summary, :failed, 2)
        notifier.notify(summary)
      end

      context 'even if there are pending examples' do
        let(:summary) { '5 examples, 1 failures (1 pending) in 4.0000 seconds' }

        it 'still notifies about failures' do
          expect_notification(summary, :failed, 2)
          notifier.notify(summary)
        end
      end
    end

    context 'with a custom title' do
      let(:options) { { notification: true, title: 'Custom title' } }

      it 'notifies with the title' do
        expect_notification('Custom title', 'This is summary', :success, -2)
        notifier.notify('This is summary')
      end
    end
  end

  context 'with notifications turned off' do
    let(:options) { { notification: false } }

    describe '#notify_failure' do
      it 'keeps quiet' do
        expect(Guard::Compat::UI).to_not receive(:notify)
        notifier.notify_failure
      end
    end

    describe '#notify' do
      it 'keeps quiet' do
        expect(Guard::Compat::UI).to_not receive(:notify)
        notifier.notify('Summary')
      end
    end
  end
end
