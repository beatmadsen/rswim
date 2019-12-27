RSpec.describe Gossip::ProtocolState do
  context 'given a simple pipe' do
    let(:pipe) { Gossip::Pipe.simple }
    subject { described_class.new(pipe) }
    it 'can be instantiated' do
      expect(subject).to be_a(described_class)
    end

    it 'has no output' do
      expect(pipe.q_out).to be_empty
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

    context "with single incoming ping from member" do
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
  end
end
