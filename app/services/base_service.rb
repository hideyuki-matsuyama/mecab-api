# サービスの基底クラス。
class BaseService
  Result = Struct.new(:success?, :payload, :error)
end
