RSpec.describe AnalysisController, type: :request do
  describe 'GET /analyze' do
    subject { get '/analyze', params: { text: text } }

    context 'params[:text] が指定されている' do
      let(:text) { 'これはテストです。python or pithon' }

      it 'OK ステータスと解析結果を返す' do
        is_expected.to eq 200
        json_response = JSON.parse(response.body)
        expect(json_response).to eq(
          {
            "payload" => [
              {
                "surface" => "これ",
                "pos" => "名詞",
                "pos_detail1" => "代名詞",
                "pos_detail2" => "一般",
                "pos_detail3" => "*",
                "base_form" => "これ",
                "reading" => "コレ"
              }, {
                "surface" => "は",
                "pos" => "助詞",
                "pos_detail1" => "係助詞",
                "pos_detail2" => "*",
                "pos_detail3" => "*",
                "base_form" => "は",
                "reading" => "ハ"
              }, {
                "surface" => "テスト",
                "pos" => "名詞",
                "pos_detail1" => "サ変接続",
                "pos_detail2" => "*",
                "pos_detail3" => "*",
                "base_form" => "テスト",
                "reading" => "テスト"
              }, {
                "surface" => "です",
                "pos" => "助動詞",
                "pos_detail1" => "*",
                "pos_detail2" => "*",
                "pos_detail3" => "*",
                "base_form" => "です",
                "reading" => "デス"
              }, {
                "surface" => "。",
                "pos" => "記号",
                "pos_detail1" => "句点",
                "pos_detail2" => "*",
                "pos_detail3" => "*",
                "base_form" => "。",
                "reading" => "。"
              }, {
                "surface" => "python",
                "pos" => "名詞",
                "pos_detail1" => "一般",
                "pos_detail2" => "*",
                "pos_detail3" => "*",
                "base_form" => "python",
                "reading" => nil
              }, {
                "surface" => "or",
                "pos" => "名詞",
                "pos_detail1" => "一般",
                "pos_detail2" => "*",
                "pos_detail3" => "*",
                "base_form" => "or",
                "reading" => nil
              }, {
                "surface" => "pithon",
                "pos" => "名詞",
                "pos_detail1" => "固有名詞",
                "pos_detail2" => "組織",
                "pos_detail3" => "*",
                "base_form" => "pithon",
                "reading" => nil
              }
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

    context 'MecabParseService がエラー' do
      let(:text) { 'エラーを発生させるテキスト' }
      let(:error_message) { 'MecabParseService 内部でエラーが発生しました' }

      before do
        allow(MecabParseService).to receive(:execute).and_return(
          MecabParseService::Result.new(success?: false, payload: nil, error: error_message)
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
