# frozen_string_literal: true
# == Schema Information
#
# Table name: masters
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  enabled    :boolean
#  sort_order :integer
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Master < ApplicationRecord
	PREFIX = 'master_'.freeze
  validates :name, presence: true, allow_blank: false
  validates :enabled, inclusion: [true, false]
  validates :sort_order, presence: true, numericality: true
  scope :contents, -> { where(enabled: true).order(:sort_order).select(:id, :name, :sort_order, :enabled) }
  scope :search_conditions_contents, -> { where(enabled: true).order(:sort_order).select(:id, :name) }
  @master_routes = {}
  @master_relations = {}

  class << self
    attr_reader :master_routes, :master_relations

    private

    def inherited(subclass)
      super
      remove_prefix(subclass)
      master_routes[subclass.model_name.route_key] = subclass.model_name.human
      master_relations[subclass.model_name.name] = subclass.model_name.singular
    end

    def remove_prefix(subclass)
      subclass.model_name.singular_route_key.gsub!(PREFIX, '')
      subclass.model_name.param_key.gsub!(PREFIX, '')
      subclass.model_name.route_key.gsub!(PREFIX, '')
    end
  end
end

Dir.glob(Rails.root.join('app', 'models', 'master', '*.rb').to_s).each { |m| require_dependency m }
