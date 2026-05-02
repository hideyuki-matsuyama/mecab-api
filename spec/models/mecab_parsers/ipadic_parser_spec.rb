RSpec.describe MecabParsers::IpadicParser, type: :model do
  let(:instance) { described_class.new }

  describe '#extract_base_form' do
    it '基本形が存在する場合はそれを返す' do
      surface = '走った'
      features = [ '動詞', '自立', '*', '*', '五段・ラ行', '過去形', '走る', 'ハシッタ', 'ハシッタ' ]
      expect(instance.send(:extract_base_form, surface, features)).to eq('走る')
    end

    it '基本形が存在しない場合は表層形を返す' do
      surface = '走った'
      features = [ '動詞', '自立', '*', '*', '五段・ラ行', '過去形', '*', 'ハシッタ', 'ハシッタ' ]
      expect(instance.send(:extract_base_form, surface, features)).to eq('走った')
    end
  end

  describe '#extract_reading' do
    it '読みが存在する場合はそれを返す' do
      features = [ '動詞', '自立', '*', '*', '五段・ラ行', '過去形', '走る', 'ハシッタ', 'ハシッタ' ]
      expect(instance.send(:extract_reading, features)).to eq('ハシッタ')
    end

    it '読みが存在しない場合は nil を返す' do
      features = [ '動詞', '自立', '*', '*', '五段・ラ行', '過去形', '走る' ]
      expect(instance.send(:extract_reading, features)).to eq(nil)
    end
  end
end
