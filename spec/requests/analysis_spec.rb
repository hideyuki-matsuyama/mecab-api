RSpec.describe AnalysisController, type: :request do
  describe 'POST /analyze' do
    subject { post '/analyze', params: { text: text } }

    context 'params[:text] が指定されている' do
      let(:text) { 'これはテストです' }

      it 'OK ステータスと解析結果を返す' do
        is_expected.to eq 200
        json_response = JSON.parse(response.body)
        expect(json_response).to eq(
          {
            "payload" => [
              { "surface" => "これ", "feature" => "名詞,代名詞,一般,*,*,*,これ,コレ,コレ" },
              { "surface" => "は", "feature" => "助詞,係助詞,*,*,*,*,は,ハ,ワ" },
              { "surface" => "テスト", "feature" => "名詞,サ変接続,*,*,*,*,テスト,テスト,テスト" },
              { "surface" => "です", "feature" => "助動詞,*,*,*,特殊・デス,基本形,です,デス,デス" }
            ]
          }
        )
      end
    end

    context 'params[:text] が指定されていない' do
      let(:text) { nil }

      it 'ok ステータスと空を返す' do
        is_expected.to eq 200
        expect(JSON.parse(response.body)).to eq({ "payload" => [] })
      end
    end

    context 'MecabParser がエラー' do
      let(:text) { 'エラーを発生させるテキスト' }
      let(:error_message) { 'MecabParser 内部でエラーが発生しました' }

      before do
        allow(MecabParser).to receive(:execute).and_return(
          MecabParser::Result.new(success?: false, payload: nil, error: error_message)
        )
      end

      it 'internal_server_error ステータスとエラーメッセージを返す' do
        is_expected.to eq 500
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({ "message" => error_message })
      end
    end
  end
end
