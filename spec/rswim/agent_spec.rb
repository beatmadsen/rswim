# frozen_string_literal: true

RSpec.describe RSwim::Agent do
  context 'when many talk together' do
    subject { Simulation.new }
    it 'will continue' do
      subject.run
    end
  end
  context 'with pre-defined message sequence' do
    subject { SingleAgentFixture.new }
    context 'with running agent' do
      before do
        subject.run
      end
      context 'with no custom state' do
        it 'will start pinging seeds' do
          subject.step
          messages = subject.new_messages_from_agent
          expected_message = {
            updates: [
              RSwim::UpdateEntry.new('test-agent', :alive, 0, {}, 0),
              RSwim::UpdateEntry.new('seed-a', :alive, 0, {}, 0),
              RSwim::UpdateEntry.new('seed-b', :alive, 0, {}, 0)
            ]
          }.then { |payload| RSwim::Message.new('seed-b', 'test-agent', :ping, payload) }

          expect(messages.size).to be(1)
          expect(messages.first).to eq(expected_message)
        end
      end

      context 'with custom state' do
        let(:custom_state) { { test: 'yes' } }
        before do
          custom_state.each { |k, v| subject.append_custom_state(k, v) }
        end
        it 'will propagate state' do
          subject.step
          messages = subject.new_messages_from_agent
          expected_message = {
            updates: [
              RSwim::UpdateEntry.new('test-agent', :alive, 1, custom_state, -10),
              RSwim::UpdateEntry.new('seed-a', :alive, 0, {}, 0),
              RSwim::UpdateEntry.new('seed-b', :alive, 0, {}, 0)
            ]
          }.then { |payload| RSwim::Message.new('seed-b', 'test-agent', :ping, payload) }

          expect(messages.size).to be(1)
          expect(messages.first).to eq(expected_message)
        end
      end
    end
  end
end
