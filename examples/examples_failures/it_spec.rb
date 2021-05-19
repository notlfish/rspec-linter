# Example of a test file with all it errors

RSpec.describe 'Ring' do
  describe '#addition' do
    it 'identity-related axioms' do
      expect(1 + -1).to eq(0)
      expect(1 + 0).to eq(1)
    end
  end

  describe '#multiplication' do
    context 'when testing identity-related axioms' do
      it 'one is multiplication identity' do
        puts 'Multiplication wtf!' unless 1 * 42 == 42
      end

      it 'nonzero numbers have multiplication inverse' do
        a = { meaning: 42 }
        expect((1 / a[:meaning]) * a[:meaning]).to eq(1.0)
      end
    end
  end
end
