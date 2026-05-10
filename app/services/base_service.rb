# サービスの基底クラス。
class BaseService
  Result = Struct.new(:success?, :payload, :error)

  def self.execute(*args)
    new(*args).execute
  end

  def execute
    raise NotImplementedError, "Subclasses must implement the execute method"
  end
end
