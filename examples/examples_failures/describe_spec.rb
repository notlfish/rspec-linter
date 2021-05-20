# Example of a test file with a bad describe message

RSpec.describe 'Ring' do
  describe '#addition' do
    context 'when testing identity-related axioms' do
      it 'zero when adding addition-inverse' do
        expect(1 + -1).to eq(0)
      end

      it 'zero is addition identity' do
        expect(1 + 0).to eq(1)
      end
    end
  end

  describe 'multiplication' do
    context 'when testing identity-related axioms' do
      it 'one is multiplication identity' do
        expect(1 * 42).to eq(42)
      end

      it 'nonzero numbers have multiplication inverse' do
        expect((1 / 42.0) * 42.0).to eq(1.0)
      end
    end
  end
end
