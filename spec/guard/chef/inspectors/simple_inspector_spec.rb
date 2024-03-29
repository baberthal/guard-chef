require 'guard/compat/test/helper'
require_relative 'shared_examples'
require 'guard/rspec/inspectors/simple_inspector'

klass = Guard::Chef::Inspectors::SimpleInspector

RSpec.describe klass do
  include_examples "inspector", klass

  # Use real paths because BaseInspector#_clean will be used to clean them
  let(:other_paths) do
    [
      "spec/guard/chef/inspectors/simple_inspector_spec.rb",
      "spec/guard/chef/runner_spec.rb"
    ]
  end

  it "returns paths and do not bothers about failed locations" do
    allow(File).to receive(:directory?)
      .with("spec/guard/chef/inspectors/base_inspector_spec.rb")
      .and_return(false)

    allow(File).to receive(:directory?)
      .with("spec/guard/chef/inspectors/simple_inspector_spec.rb")
      .and_return(false)

    allow(File).to receive(:directory?)
      .with("spec/guard/chef/runner_spec.rb")
      .and_return(false)

    allow(File).to receive(:directory?)
      .with("spec/guard/chef/deprecator_spec.rb")
      .and_return(false)

    allow(Dir).to receive(:[]).with("spec/**{,/*/**}/*[_.]spec.rb")
      .and_return(paths + other_paths)

    allow(Dir).to receive(:[]).with("spec/**{,/*/**}/*.feature")
      .and_return([])

    allow(Dir).to receive(:[]).with("myspec/**{,/*/**}/*[_.]spec.rb")
      .and_return([])

    allow(Dir).to receive(:[]).with("myspec/**{,/*/**}/*.feature")
      .and_return([])

    expect(inspector.paths(paths)).to eq(paths)
    inspector.failed(failed_locations)
    expect(inspector.paths(other_paths)).to eq(other_paths)
    inspector.failed([])

    expect(inspector.paths(paths)).to eq(paths)
    inspector.failed(failed_locations)
    expect(inspector.paths(other_paths)).to eq(other_paths)
    inspector.failed([])
  end
end
