RSpec.describe Gossip::ProtocolState do
  subject { described_class.new('me', [], Gossip::T_MS, Gossip::R_MS) }
  it 'can be instantiated' do
    expect(subject).to be_a(described_class)
  end

  context 'without incoming messages' do
    let!(:out) do
      subject.advance([], Gossip::T_MS / 1000.0)
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
        subject.advance([Gossip::Message::Inbound.new('a', :ping)], 0)
      end
      let!(:ack_message) { out1.first }

      it 'outputs an ack for member' do
        expect(ack_message).to have_attributes(to: 'a', type: :ack)
      end

      context 'after an additional T period and a tick' do
        before do
          subject.advance([], Gossip::T_MS / 1000.0)
        end

        let!(:out2) do
          subject.advance([], 0)
        end

        let(:ping_message) { out2.first }

        it 'outputs a ping for member' do
          expect(ping_message).to have_attributes(to: 'a', type: :ping)
        end
      end
    end
  end

  context 'with multiple members and one suspected' do
    before do
      inputs = ('a'..'z').map { |member| Gossip::Message::Inbound.new(member, :ping) }
      subject.advance(inputs, 0)
      subject.advance([], Gossip::T_MS / 1000.0)
      subject.advance([], 0)
      subject.advance([], Gossip::R_MS / 1000.0)
      subject.advance([], Gossip::R_MS + 1 / 1000.0)
    end

    context 'and an Alive payload for the suspected member is received' do
      it 'clears the suspicion and does not send out a Confirmed payload' do
        fail('TODO')
      end
    end

    context 'and nothing further is heard from the member' do
      it 'sends out a Confirmed payload in next outbound message' do
        fail('TODO')
      end
    end
  end
end
