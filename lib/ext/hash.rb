class Hash
  def symbolize_keys
    self.inject({}) do |symbolized, (key, value)|
      value = case value
      when Array
        value.map{|v| v.is_a?(Hash) ? v.symbolize_keys : v }
      when Hash
        value.symbolize_keys
      else
        value
      end
      symbolized[(key.to_sym rescue key) || key] = value
      symbolized
    end
  end
end
