module MecabParsers
  # IPADIC の解析結果を共通の形式に変換するためのクラス。
  class IpadicParser < BaseParser
    private

    def extract_base_form(surface, features)
      val = features[6]
      (val.nil? || val == "*") ? surface : val
    end

    def extract_reading(features)
      # 未知語などで欠落していれば nil
      features[7]
    end
  end
end
