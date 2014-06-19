module Bandiera
  class APIv2 < WebAppBase
    get '/all' do
      group_map = {}

      feature_service.get_groups.each do |group|
        features = feature_service.get_group_features(group.name)
        group_map[group.name] = features_enabled_hash(features)
      end

      json_or_jsonp(response: group_map)
    end

    get '/groups/:group_name/features' do |group_name|
      response = { response: features_enabled_hash([]) }

      begin
        features            = feature_service.get_group_features(group_name)
        response[:response] = features_enabled_hash(features)
      rescue Bandiera::FeatureService::GroupNotFound => e
        response[:warning] = e.message
      end

      json_or_jsonp(response)
    end

    get '/groups/:group_name/features/:feature_name' do |group_name, feature_name|
      feature   = Bandiera::Feature.stub_feature(feature_name, group_name)
      response  = { response: feature_enabled?(feature) }

      if feature.percentage && !params[:user_id]
        raise "you need to pass a user id"
      end

      if feature.percentage
        user_id   = params[:user_id]
        user_feature = feature_service.get_user_feature(user_id, feature)
        response[:response] = feature_enabled_for_user?(feature, user_feature)
      else
        begin
          feature             = feature_service.get_feature(group_name, feature_name)
          response[:response] = feature_enabled?(feature)
        rescue *[Bandiera::FeatureService::GroupNotFound, Bandiera::FeatureService::FeatureNotFound] => e
          response[:warning] = e.message
        end
      end

      json_or_jsonp(response)
    end

    private

    def current_user_group
      params[:user_group]
    end

    def feature_enabled?(feature)
      feature.enabled?(user_group: current_user_group)
    end

    def feature_enabled_for_user?(feature, user_feature)
      feature.enabled_for_user?(user_feature)
    end

    def features_enabled_hash(features)
      map = {}

      features.each do |feature|
        map[feature.name] = feature_enabled?(feature)
      end

      map
    end

    def json_or_jsonp(data)
      callback = params.delete('callback')
      json     = JSON.generate(data)

      if callback
        content_type :js
        "#{callback}(#{json})"
      else
        content_type :json
        json
      end
    end
  end
end
