class BaseSerializer < ActiveModel::Serializer
  def attributes(*)
    attributes = self.class._attributes
    type = instance_options[:type] || "DEFAULT"
    attributes = self.class.const_get(type) if self.class.const_defined? type

    extract attributes
  end

  private
  def extract attrs
    attrs.each_with_object({}) do |name, hash|
      next hash[name] = public_send(name) if respond_to? name

      hash[name] = object.send(name)
    end
  end
end
