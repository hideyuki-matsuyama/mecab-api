# MeCabを使用してテキストを解析するためのサービスクラス。
class MecabParser
  # 指定されたテキストをMeCabで形態素解析し、結果を返します。
  # 解析結果はキャッシュされ、1 時間有効です。
  #
  # @param text [String] 解析対象のテキスト。
  # @return [Array<Hash>] 形態素解析の結果の配列。
  #   各ハッシュは以下のキーを持ちます:
  #   - `:surface` [String] 表層形。
  #   - `:feature` [String] 品詞などの素性情報。
  def self.parse(text)
    Rails.cache.fetch(text, expires_in: 1.hours) do
      ret = []
      Natto::MeCab.new.parse(text) do |mecab_node|
        ret << { surface: mecab_node.surface, feature: mecab_node.feature } unless mecab_node.is_eos?
      end
      ret
    end
  end
end
