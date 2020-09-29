RSpec.describe Gossip::Agent do
  context 'when many talk together' do
    subject { Simulation.new }
    it "will continue" do
      subject.run
    end
  end
end
