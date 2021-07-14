if model.nil? && controller_name == "application"
  routes = Rails.application.routes.routes.reject(&:internal).collect do |route|
    { name: route.name,
      verb: route.verb,
      path: route.path.spec.to_s.gsub(/\(\.format\)\Z/, ''),
      controller: route.requirements[:controller],
      action: route.requirements[:action],
      array: ['index'].include?(route.requirements[:action]) }
  end

  json.set! 'comment', ActiveRecord::Base.connection.database_comment

  json.set! 'routes' do
    json.array!(routes) do |route|
      controller = if controller_name = route[:controller]
        begin
          controller_param = controller_name.underscore
          const_name = "#{controller_param.camelize}Controller"
          const = ActiveSupport::Dependencies.constantize(const_name)
          if const.ancestors.include?(StandardAPI::Controller)
            const
          else
            nil
          end
        rescue NameError
        end
      end

      next if controller.nil?

      resource_limit = controller.resource_limit if controller.respond_to?(:resource_limit)
      resource_attributes = if controller.respond_to?(:model_attributes)
        controller.model_attributes&.select { |x| controller.model.has_attribute?(x) }&.inject({}) do |acc, attr_name|
          model = controller.model
          column = model.columns_hash[attr_name.to_s]
          acc[attr_name] = {
            type: json_column_type(column.sql_type),
            default: column.default ? model.connection.lookup_cast_type_from_column(column).deserialize(column.default) : nil,
            primary_key: column.name == model.primary_key,
            null: column.null,
            array: column.array,
            comment: column.comment
          }
          acc
        end
      end
      resource_orders = controller.model_orders if controller.respond_to?(:model_orders)
      resource_includes = controller.model_includes if controller.respond_to?(:model_includes)

      json.set! 'path', route[:path]
      json.set! 'method', route[:verb]
      json.set! 'model', controller.model&.name
      json.set! 'array', route[:array]
      json.set! 'limit', resource_limit
      json.set! "wheres", resource_attributes
      json.set! 'orders', resource_orders
      json.set! 'includes', resource_includes
    end
  end

  json.set! 'models' do
    models.each do |model|
      json.set! model.name do
        json.partial! partial: schema_partial(model), model: model
      end
    end
  end

else

  json.set! 'attributes' do
    model.columns.each do |column|
      json.set! column.name, {
        type: json_column_type(column.sql_type),
        default: column.default ? model.connection.lookup_cast_type_from_column(column).deserialize(column.default) : nil,
        primary_key: column.name == model.primary_key,
        null: column.null,
        array: column.array,
        comment: column.comment
      }
    end
  end

  json.set! 'limit', resource_limit # This should be removed?
  json.set! 'comment', model.connection.table_comment(model.table_name)

end

