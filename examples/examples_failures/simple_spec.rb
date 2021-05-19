RSpec.describe 'Ring' do
  describe 'not so simple anymore' do
    context 'when given a context' do
      it 'zero when adding addition-inverse' do
        expect(1 + -1).to eq(0)
      end
    end
  end
end
