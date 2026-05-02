module MecabParsers
  # feature の構造が異なる辞書（IPADIC、UniDic など）に対応するための抽象クラス。
  class BaseParser
    def self.parse_feature(surface, feature_string)
      features = feature_string.split(",")
      {
        surface: surface,
        pos: features[0], # 品詞（大分類）
        pos_detail1: features[1], # 品詞細分類1
        pos_detail2: features[2], # 品詞細分類2
        pos_detail3: features[3], # 品詞細分類3
        base_form: extract_base_form(surface, features), # 基本形
        reading: extract_reading(features) # 読み
      }
    end

    def self.extract_base_form(surface, features)
      raise NotImplementedError
    end

    def self.extract_reading(features)
      raise NotImplementedError
    end

    private_class_method :extract_base_form, :extract_reading
  end
end
