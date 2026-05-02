module MecabParsers
  # UniDic の解析結果を共通の形式に変換するためのクラス。
  class UnidicParser < BaseParser
    def self.extract_base_form(surface, features)
      val = features[10]
      (val.nil? || val == "*") ? surface : val
    end

    def self.extract_reading(features)
      features[17]
    end

    private_class_method :extract_base_form, :extract_reading
  end
end
