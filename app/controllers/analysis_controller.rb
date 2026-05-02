# 形態素解析リクエストを処理します。
class AnalysisController < ApplicationController
  # 指定されたテキストを MeCab を使用して解析します。
  #
  # @param [String] text 解析対象のテキスト (params[:text] 経由で渡されます)。
  # @return [void] 解析データまたはエラーメッセージを含む JSON レスポンス
  def parse
    text = params[:text]
    result = MecabParseService.execute(text)

    if result.success?
      render json: { payload: result.payload }, status: :ok
    else
      render json: { message: result.error }, status: :internal_server_error
    end
  end
end
