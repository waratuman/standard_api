require 'rails'
require 'action_view'
require 'action_pack'
require 'action_controller'
require 'jbuilder'
require 'jbuilder/railtie'
require 'active_record/filter'
require 'active_record/sort'
require 'active_support/core_ext/hash/indifferent_access'

module StandardAPI
end

require 'standard_api/orders'
require 'standard_api/includes'
require 'standard_api/controller'
require 'standard_api/helpers'
require 'standard_api/railtie'
