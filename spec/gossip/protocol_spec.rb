RSpec.describe Gossip::Protocol do
  context 'when many talk together' do
    subject { Agent.new }
    it "will continue" do
      subject.run
    end
  end
end
