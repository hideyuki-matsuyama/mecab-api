# MeCab を使用してテキストを解析するためのサービスクラス。
class MecabParseService < BaseService
  attr_accessor :text

  def initialize(text)
    @text = text
  end

  # 指定されたテキストを MeCab で形態素解析し、結果を返します。
  # 解析結果はキャッシュされ、1 時間有効です。
  #
  # @param text [String] 解析対象のテキスト。
  # @return [Result] 処理結果オブジェクト。
  # @raise [MecabParseError] 解析中にエラーが発生した場合。
  def execute
    return Result.new(success?: true, payload: []) if text.blank?

    payload = Rails.cache.fetch(text, expires_in: 1.hours) { parse }
    Result.new(success?: true, payload: payload)
  rescue MecabParseError => e
    Rails.logger.error("[#{self.class.name}] 解析に失敗しました: #{e.message}")
    Result.new(success?: false, error: e.message)
  end

  private

  # テキストを MeCab で形態素解析し、結果をハッシュの配列として返す。
  #
  # @return [Array<Hash>] 形態素解析の結果の配列。
  # @raise [MecabParseError] MeCab の内部エラーや予期せぬエラー。
  # @private
  def parse
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

  # @private
  def parser
    case ENV["MECAB_DIC_TYPE"]
    when "unidic"
      MecabParsers::UnidicParser
    else
      MecabParsers::IpadicParser
    end
  end
end
