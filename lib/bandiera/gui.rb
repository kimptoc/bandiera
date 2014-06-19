require 'rack-flash'

module Bandiera
  class GUI < WebAppBase
    configure do
      set :root, File.join(File.dirname(__FILE__), 'gui')
      enable :sessions
    end

    use Rack::Flash

    get '/' do
      @groups_and_features = feature_service.get_groups.map do |group|
        { name: group.name, features: feature_service.get_group_features(group.name) }
      end

      erb :index
    end

    # Groups.

    get '/new/group' do
      erb :new_group
    end

    post '/create/group' do
      group_name = params[:group][:name]

      if param_present?(group_name)
        feature_service.add_group(group_name)
        flash[:success] = 'Group created.'
        redirect '/'
      else
        flash[:danger] = 'You must enter a group name.'
        redirect '/new/group'
      end
    end

    # Features.

    get '/new/feature' do
      @groups = feature_service.get_groups

      erb :new_feature
    end

    post '/create/feature' do
      feature = process_v2_feature_params(params[:feature])

      with_valid_feature_params(feature, '/new/feature') do
        feature_service.add_feature(feature)
        flash[:success] = 'Feature created.'
        redirect '/'
      end
    end

    get '/groups/:group_name/features/:feature_name/edit' do |group_name, feature_name|
      @groups  = feature_service.get_groups
      @feature = feature_service.get_feature(group_name, feature_name)

      erb :edit_feature
    end

    post '/update/feature' do
      prev_group  = params[:feature][:previous_group]
      prev_name   = params[:feature][:previous_name]
      new_feature = process_v2_feature_params(params[:feature])

      with_valid_feature_params(new_feature, "/groups/#{prev_group}/features/#{prev_name}/edit") do
        feature_service.update_feature(prev_group, prev_name, new_feature)
        flash[:success] = 'Feature updated.'
        redirect '/'
      end
    end

    put '/update/feature/active_toggle' do
      feat_params = params[:feature] || {}
      group       = feat_params[:group]
      name        = feat_params[:name]
      active      = feat_params[:active] == 'true'

      if group && name && !active.nil?
        feature_service.update_feature(group, name, { active: active })
        status 200
        content_type :json
        "{}"
      else
        status 401
        halt
      end
    end

    get '/groups/:group_name/features/:feature_name/delete' do |group_name, feature_name|
      feature_service.remove_feature(group_name, feature_name)
      flash[:success] = 'Feature deleted.'
      redirect '/'
    end

    private

    def with_valid_feature_params(feature, on_error_url, &block)
      if valid_params?(feature)
        yield
      else
        errors = []
        errors << 'enter a feature name' unless param_present?(feature[:name])
        errors << 'enter a feature name without spaces' if feature[:name].include?(' ')
        errors << 'select a group' unless param_present?(feature[:group])
        errors << 'use either percentage or groups of users' unless valid_user_filters?(feature)
        flash[:danger] = "You must #{errors.join(" and ")}."
        redirect on_error_url
      end
    end

    def param_present?(param)
      param && !param.empty?
    end
  end
end
