RSpec.describe MecabParser, type: :service do
  describe '.parse' do
    subject { described_class.parse(text) }

    let(:text) { 'これはテストです' }
    let(:expected_results) do
      [
       { surface: "これ", feature: "名詞,代名詞,一般,*,*,*,これ,コレ,コレ" },
       { surface: "は", feature: "助詞,係助詞,*,*,*,*,は,ハ,ワ" },
       { surface: "テスト", feature: "名詞,サ変接続,*,*,*,*,テスト,テスト,テスト" },
       { surface: "です", feature: "助動詞,*,*,*,特殊・デス,基本形,です,デス,デス" }
      ]
    end

    context '初めて解析されるテキストの場合' do
      it 'MeCab で解析し、結果をキャッシュして返す' do
        expect_any_instance_of(Natto::MeCab).to receive(:parse).with(text).and_call_original
        is_expected.to eq expected_results
      end
    end

    context '既にキャッシュされているテキストの場合' do
      before { Rails.cache.write(text, expected_results, expires_in: 1.hour) }

      it 'キャッシュされた結果を返し、MeCab は実行されない' do
        expect_any_instance_of(Natto::MeCab).not_to receive(:parse)
        is_expected.to eq expected_results
      end
    end
  end
end
