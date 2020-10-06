RSpec.describe RSwim::ProtocolState do
  subject { described_class.new('me', [], RSwim::T_MS, RSwim::R_MS) }
  it 'can be instantiated' do
    expect(subject).to be_a(described_class)
  end

  context 'without incoming messages' do
    let!(:out) do
      subject.advance([], RSwim::T_MS / 1000.0)
    end

    context 'after first protocol period' do
      it 'has no output' do
        expect(out).to be_empty
      end
    end
  end

  context 'with single incoming ping from member' do
    context 'after first tick' do
      let!(:out1) do
        subject.advance([RSwim::Message.new('me', 'a', :ping)], 0)
      end
      let!(:ack_message) { out1.first }

      it 'outputs an ack for member' do
        expect(ack_message).to have_attributes(to: 'a', type: :ack)
      end

      context 'after an additional T period' do

        let!(:out2) do
          subject.advance([], RSwim::T_MS / 1000.0)
        end

        let(:ping_message) { out2.first }

        it 'outputs a ping for member' do
          expect(ping_message).to have_attributes(to: 'a', type: :ping)
        end
      end
    end
  end
end
