module StandardAPI
  module Sorts

    def self.sanitize(sorts, permit)
      return nil if sorts.nil?

      permit = [permit] if !permit.is_a?(Array)
      permit = permit.flatten.map { |x| x.is_a?(Hash) ? x.with_indifferent_access : x.to_s }
      permitted = []

      case sorts
      when Hash, ActionController::Parameters
        sorts.each do |key, value|
          if key.to_s.count('.') == 1
            key2, key3 = *key.to_s.split('.')
            permitted << sanitize({key2.to_sym => { key3.to_sym => value } }, permit)
          elsif permit.include?(key.to_s)
            value = case value
            when Hash
              value
            when ActionController::Parameters
              value.permit([:asc, :desc]).to_h
            else
              value
            end
            permitted << { key.to_sym => value }
          elsif permit.find { |x| (x.is_a?(Hash) || x.is_a?(ActionController::Parameters)) && x.has_key?(key.to_s) }
            subpermit = permit.find { |x| (x.is_a?(Hash) || x.is_a?(ActionController::Parameters)) && x.has_key?(key.to_s) }[key.to_s]
            sanitized_value = sanitize(value, subpermit)
            permitted << { key.to_sym => sanitized_value }
          else
            raise(StandardAPI::UnpermittedParameters.new([sorts]))
          end
        end
      when Array
        sorts.each do |sort|
          sort = sanitize(sort, permit)
          if sort.is_a?(Array)
            permitted += sort
          else
            permitted << sort
          end
        end
      else
        if sorts.to_s.count('.') == 1
          key, value = *sorts.to_s.split('.')
          permitted = sanitize({key.to_sym => value.to_sym}, permit)
        elsif permit.include?(sorts.to_s)
          permitted = sorts
        else
          raise(StandardAPI::UnpermittedParameters.new([sorts]))
        end
      end

      if permitted.is_a?(Array) && permitted.length == 1
        permitted.first
      else
        permitted
      end
    end

  end
end
