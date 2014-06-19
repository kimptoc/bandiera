module Bandiera
  class Feature < Sequel::Model
    many_to_one :group

    plugin :serialization

    serialize_attributes :json, :user_groups

    alias :active? :active

    def self.stub_feature(name, group)
      new(name: name, group: Group.find_or_create(name: group), description: '')
    end

    def enabled?(opts={ user_group: nil })
      return false unless active?

      user_group = opts[:user_group]

      if user_groups_configured?
        enabled = false

        if !user_groups_list.empty? && cleaned_user_groups_list.include?(user_group)
          enabled = true
        end

        if !user_groups_regex.empty?
          regexp = Regexp.new(user_groups_regex)
          enabled = true if regexp.match(user_group)
        end

        enabled
      else
        true
      end
    end

    def enabled_for_user?(user_feature)
      Zlib.crc32(user_feature.index.to_s) % 100 < self.percentage
    end

    def user_groups_list
      user_groups.fetch(:list, [])
    end

    def user_groups_regex
      user_groups.fetch(:regex, '')
    end

    def user_groups_configured?
      !(user_groups_list.empty? && user_groups_regex.empty?)
    end

    def as_v1_json
      {
        group:       group.name,
        name:        name,
        description: description,
        enabled:     enabled?
      }
    end

    def as_v2_json
      {
        group:        group.name,
        name:         name,
        description:  description,
        active:       enabled?,
        user_groups:  user_groups
      }
    end

    private

    def cleaned_user_groups_list
      user_groups_list.reject { |elm| elm.nil? || elm.empty? }
    end
  end
end
