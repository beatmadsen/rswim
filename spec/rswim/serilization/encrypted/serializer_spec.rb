RSpec.describe RSwim::Serialization::Encrypted::Serializer do
  before do
    RSwim.encrypted = true
    RSwim.shared_secret = 'potato'
  end

  let(:directory) { RSwim::Directory.new }

  subject { described_class.new(directory) }

  it 'can be instantiated' do
    expect(subject).to be_a(described_class)
  end

  context 'given a deserialized message' do
    let(:simple_deserializer) { RSwim::Serialization::Simple::Deserializer.new(directory, 42) }
    let(:encrypted_deserializer) { RSwim::Serialization::Encrypted::Deserializer.new(directory, 42) }

    let(:simple_wire_message) do
      m = <<~EOS
        ping-req 192.168.19.24
        192.168.19.12 alive 1 custom-key: custom-value other-k: other-v dingo: 3
        192.168.19.13 suspected 3
        192.168.19.14 alive 2 meltdown: 2
        192.168.19.15 alive 4
      EOS
      m.strip
    end

    let(:message) { simple_deserializer.deserialize('sender', simple_wire_message) }


    it 'can go back and forth' do
      result = subject.serialize(message)
      deserialized_again = encrypted_deserializer.deserialize('sender', result)

      expect(deserialized_again).to eq(message)
    end
  end
end
