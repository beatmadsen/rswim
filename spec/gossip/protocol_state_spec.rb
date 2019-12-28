RSpec.describe Gossip::ProtocolState do
  let(:pipe) { Gossip::Pipe.simple }
  subject { described_class.new(pipe) }
  it 'can be instantiated' do
    expect(subject).to be_a(described_class)
  end

  context 'without incoming messages' do
    context 'after first protocol period' do
      before do
        subject.advance(Gossip::T_MS / 1000.0)
      end

      it 'has no output' do
        expect(pipe.q_out).to be_empty
      end
    end
  end

  context 'with single incoming ping from member' do
    before do
      pipe.q_in << %w[a ping]
    end
    context 'after first tick' do
      before do
        subject.advance(0)
      end

      let!(:ack_message) { pipe.q_out.pop(true) }

      it 'outputs an ack for member' do
        expect(ack_message).to eq(%w[a ack])
      end

      context 'after an additional T period and a tick' do
        before do
          subject.advance(Gossip::T_MS / 1000.0)
          subject.advance(0)
        end

        let!(:ping_message) { pipe.q_out.pop(true) }

        it 'outputs a ping for member' do
          expect(ping_message).to eq(%w[a ping])
        end
      end
    end
  end

  context 'with multiple members and one suspected' do
    before do
      ('a'..'z').each { |member| pipe.q_in << [member, "ping"] }
      subject.advance(0)
      subject.advance(Gossip::T_MS / 1000.0)
      subject.advance(0)
      subject.advance(Gossip::R_MS / 1000.0)
      subject.advance(Gossip::R_MS + 1 / 1000.0)
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
