module MecabParsers
  # UniDic の解析結果を共通の形式に変換するためのクラス。
  class UnidicParser < BaseParser
    private

    def extract_base_form(surface, features)
      val = features[10]
      (val.nil? || val == "*") ? surface : val
    end

    def extract_reading(features)
      features[17]
    end
  end
end
