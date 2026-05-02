# MeCab を使用してテキストを解析するためのサービスクラス。
class MecabParseService < BaseService
  # 指定されたテキストを MeCab で形態素解析し、結果を返します。
  # 解析結果はキャッシュされ、1 時間有効です。
  #
  # @param text [String] 解析対象のテキスト。
  # @return [Result] 処理結果オブジェクト。
  # @raise [MecabParseError] 解析中にエラーが発生した場合。
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

  # テキストを MeCab で形態素解析し、結果をハッシュの配列として返す。
  #
  # @param text [String] 解析対象のテキスト。
  # @return [Array<Hash>] 形態素解析の結果の配列。
  # @raise [MecabParseError] MeCab の内部エラーや予期せぬエラー。
  # @private
  def self.parse(text)
    ret = []

    begin
      Natto::MeCab.new.parse(text) do |mecab_node|
        ret << parser.parse_feature(mecab_node.surface, mecab_node.feature) unless mecab_node.is_eos?
      end
    rescue Natto::MeCabError => e
      raise MecabParseError, "MeCab 内部エラー: #{e.message}"
    rescue => e
      raise MecabParseError, "予期せぬエラーが発生しました (#{e.class}): #{e.message}"
    end

    ret
  end

  def self.parser
    case ENV["MECAB_DIC_TYPE"]
    when "unidic"
      MecabParsers::UnidicParser
    else
      MecabParsers::IpadicParser
    end.new
  end

  private_class_method :parse, :parser
end
