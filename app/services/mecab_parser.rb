# MeCab を使用してテキストを解析するためのサービスクラス。
class MecabParser < BaseService
  # 指定されたテキストを MeCab で形態素解析し、結果を返します。
  # 解析結果はキャッシュされ、1 時間有効です。
  #
  # @param text [String] 解析対象のテキスト。
  # @return [Result] 処理結果オブジェクト。
  #   - `success?` [Boolean] 処理が成功した場合は `true`、失敗した場合は `false`。
  #   - `payload` [Array<Hash>, nil] 成功時には形態素解析の結果の配列。各ハッシュは以下のキーを持ちます:
  #     - `:surface` [String] 表層形。
  #     - `:feature` [String] 品詞などの素性情報。
  #     失敗時には `nil`。
  #   - `error` [String, nil] 失敗時にはエラーメッセージ。成功時には `nil`。
  # @raise [MecabParseError] 内部の `parse` メソッドでエラーが発生した場合に再スローされます。
  def self.execute(text)
    return Result.new(success?: true, payload: []) if text.blank?

    payload = Rails.cache.fetch(text, expires_in: 1.hours) do
      self.parse text
    end
    Result.new(success?: true, payload: payload)
  rescue MecabParseError => e
    Rails.logger.error("[#{self.name}] 解析に失敗しました: #{e.message}")
    Result.new(success?: false, error: e.message)
  end

  # テキストを MeCab で形態素解析し、結果をハッシュの配列として返します。
  # このメソッドはプライベートであり、`execute` メソッドからのみ呼び出されます。
  #
  # @param text [String] 解析対象のテキスト。
  # @return [Array<Hash>] 形態素解析の結果の配列。
  #   各ハッシュは以下のキーを持ちます:
  #   - `:surface` [String] 表層形。
  #   - `:feature` [String] 品詞などの素性情報。
  # @raise [MecabParseError] MeCab の内部エラー (`Natto::MeCabError`) や
  #   その他の予期せぬエラーが発生した場合に、詳細なメッセージとともに発生します。
  # @private
  def self.parse(text)
    ret = []

    begin
      Natto::MeCab.new.parse(text) do |mecab_node|
        ret << { surface: mecab_node.surface, feature: mecab_node.feature } unless mecab_node.is_eos?
      end
    rescue Natto::MeCabError => e
      raise MecabParseError, "MeCab 内部エラー: #{e.message}"
    rescue => e
      raise MecabParseError, "予期せぬエラーが発生しました (#{e.class}): #{e.message}"
    end

    ret
  end

  private_class_method :parse
end
