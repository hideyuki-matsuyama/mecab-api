# 形態素解析リクエストを処理します。
class AnalysisController < ApplicationController
  # 指定されたテキストを MeCab を使用して解析します。
  #
  # @param text [String] 解析対象のテキスト (params[:text] 経由で渡されます)。
  # @return [void] 解析データまたはエラーメッセージを含む JSON レスポンスをレンダリングします。
  def parse
    text = params[:text]
    if text.present?
      render json: { status: "success", data: MecabParser.execute(text) }
    else
      render json: { status: "error", message: "Text is required" }, status: :bad_request
    end
  end
end
