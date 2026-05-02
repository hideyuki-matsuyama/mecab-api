RSpec.describe MecabParser, type: :service do
  describe '.execute' do
    subject { MecabParser.execute(text) }

    let(:text) { 'こんにちは' }
    let(:parsed_result) { [ { surface: 'こんにちは', feature: '感動詞', stat: 0 } ] }

    describe 'キャッシュの制御' do
      it 'キャッシュがない場合は .parse を呼び出し、結果をキャッシュすること' do
        expect(Rails.cache.read(text)).to eq(nil)
        expect(described_class).to receive(:parse).with(text).and_return(parsed_result)
        expect(Rails.cache).to receive(:fetch).with(text, expires_in: 1.hour).and_call_original

        ret = subject
        expect(ret.success?).to eq(true)
        expect(ret.payload).to eq(parsed_result)
        expect(Rails.cache.read(text)).to eq(parsed_result) # キャッシュあり
      end

      it 'キャッシュがある場合は .parse を呼び出さずキャッシュを返す' do
        expect(described_class).to receive(:parse).with(text).and_return(parsed_result)
        subject # 1 回目の実行
        expect(Rails.cache.read(text)).to eq(parsed_result) # キャッシュあり

        expect(described_class).not_to receive(:parse).with(text)
        ret = MecabParser.execute(text) # 2 回目の実行（subject は RSpec がキャッシュするので明示的に呼び出す）
        expect(ret.payload).to eq(parsed_result)
      end
    end

    context 'text がブランク' do
      let(:text) { '' }

      it '空の配列を含む成功結果を返す' do
        ret = subject
        expect(ret.success?).to be true
        expect(ret.payload).to eq([])
        expect(ret.error).to be_nil
      end
    end

    context 'text が nil' do
      let(:text) { nil }

      it '空の配列を含む成功結果を返す' do
        ret = subject
        expect(ret.success?).to be true
        expect(ret.payload).to eq([])
        expect(ret.error).to be_nil
      end
    end

    context '解析中にエラーが発生した場合' do
      let(:error_message) { 'テスト用の解析エラー' }

      before do
        allow(described_class).to receive(:parse).and_raise(MecabParseError, error_message)
        allow(Rails.logger).to receive(:error) # ログ出力をスタブ
      end

      it '失敗結果とエラーメッセージを返す' do
        ret = subject
        expect(ret.success?).to be false
        expect(ret.payload).to be_nil
        expect(ret.error).to eq(error_message)
      end

      it 'エラーログが出力されること' do
        subject
        expect(Rails.logger).to have_received(:error).with("[#{described_class.name}] 解析に失敗しました: #{error_message}")
      end
    end
  end

  # private methods

  describe '.parse' do
    subject { MecabParser.send(:parse, text) }

    let(:text) { 'こんにちは' }

    it 'MeCab のノードを正しくハッシュの配列に変換すること' do
      node = double('Natto::MeCabNode', surface: 'こんにちは', feature: '感動詞', stat: 0, is_eos?: false)
      eos = double('Natto::MeCabNode', is_eos?: true)
      mecab_mock = instance_double(Natto::MeCab)

      allow(Natto::MeCab).to receive(:new).and_return(mecab_mock)
      expect(mecab_mock).to receive(:parse).with(text).and_yield(node).and_yield(eos)
      is_expected.to eq([ { surface: 'こんにちは', feature: '感動詞', stat: 0 } ])
    end
  end

  describe '.parse のエラーハンドリング' do
    subject { MecabParser.send(:parse, text) }

    let(:text) { 'エラー発生テキスト' }

    context 'MeCab 内部で Natto::MeCabError が発生した場合' do
      let(:mecab_error_message) { 'MeCab library error' }

      before do
        mecab_mock = instance_double(Natto::MeCab)
        allow(Natto::MeCab).to receive(:new).and_return(mecab_mock)
        allow(mecab_mock).to receive(:parse).and_raise(Natto::MeCabError, mecab_error_message)
      end

      it 'MecabParseError を発生させること' do
        expect { subject }.to raise_error(MecabParseError, "MeCab 内部エラー: #{mecab_error_message}")
      end
    end

    context 'MeCab 内部で予期せぬエラーが発生した場合' do
      let(:unexpected_error_message) { 'Something went wrong' }

      before do
        mecab_mock = instance_double(Natto::MeCab)
        allow(Natto::MeCab).to receive(:new).and_return(mecab_mock)
        allow(mecab_mock).to receive(:parse).and_raise(StandardError, unexpected_error_message)
      end

      it 'MecabParseError を発生させること' do
        expect { subject }.to raise_error(MecabParseError, "予期せぬエラーが発生しました (StandardError): #{unexpected_error_message}")
      end
    end
  end
end
