RSpec.describe RSwim::Pipe do
  context 'simple' do
    subject { described_class.simple}
    it "can be instantiated" do      
      expect(subject).to be_a(described_class)
    end
  end
end
