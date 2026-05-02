module MecabParsers
  # IPADIC の解析結果を共通の形式に変換するためのクラス。
  class IpadicParser < BaseParser
    def self.extract_base_form(surface, features)
      val = features[6]
      (val.nil? || val == "*") ? surface : val
    end

    def self.extract_reading(features)
      # 未知語などで欠落していれば nil
      features[7]
    end

    private_class_method :extract_base_form, :extract_reading
  end
end
