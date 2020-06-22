class RedmineDestinationBbsController < ApplicationController
  unloadable
  accept_api_auth :index

  def index

    # 検索(日付・グループ)
    @search_params = destination_bbs_search_params

    # グループ名・ID取得
    @groups = User.where(type: 'Group').select('id', 'lastname')

    # ユーザーID→名前変換用データ取得
    @users = User.select('id', 'lastname', 'firstname')
    # 在勤地情報の取得
    @custom_values = get_working_in_place

    # グループ名取得
    scope = Group.sorted.where(type: 'Group')
    @groups = scope.to_a

    # フォーマット毎に処理を分ける
    respond_to do |format|
      format.html do
        # グループすべて選択時
        if @search_params[:group_id].blank? || @search_params[:group_id] == l(:select_all)
          group_id_list = []
          @groups.each do |g|
            group_id_list << g.id
          end
          @search_params[:group_id] = group_id_list
          @select_group_id = l(:select_all)
        else
          @select_group_id = @search_params[:group_id]
        end
        # グループ検索用
        @search_group_users = User.joins(:groups).where(users_groups_users_join: { group_id: @search_params[:group_id]}) if @search_params[:group_id].present?
        group_user_id_list = []
        if @search_group_users.blank?
        else
          @search_group_users.each do |group_user|
            group_user_id_list << group_user.id
          end
        end
        # 日付欄が空欄の場合(初期表示時)は表示時点の日付データを取得する
        if @search_params[:registration_date].blank?
          if params[:registration_date].blank?
            @destination_bbs = RedmineDestinationBbsModel.where(registration_date: Date.today, user_id: group_user_id_list)
            @search_params[:registration_date] = Date.today
            @search_params_date = Date.today
          else
            @destination_bbs = RedmineDestinationBbsModel.where(registration_date:  params[:registration_date], user_id: group_user_id_list)
            @search_params[:registration_date] = params[:registration_date]
            @search_params_date = params[:registration_date]
          end
        else
          @destination_bbs = RedmineDestinationBbsModel.search(@search_params).where(user_id: group_user_id_list)
          @search_params_date = @search_params[:registration_date]
        end

        # 登録用ユーザーIDの取得
        @user_id = User.current.attributes["id"]
        # 本人登録済レコードのID取得
        @destination_bbs_id = RedmineDestinationBbsModel.where(user_id: @user_id, registration_date: @search_params[:registration_date]).select('id')
        # グループユーザー一覧表示用
        if @search_group_users.blank?
          @search_group_users_list = ''
        else
          @search_group_users_list = get_group_user_list(@destination_bbs)
        end
      end
      format.csv do
        # グループすべて選択時
        if params[:group_id].blank? || params[:group_id] == l(:select_all)
          group_id_list = []
          @groups.each do |g|
            group_id_list << g.id
          end
          params[:group_id] = group_id_list
          @select_group_id = l(:select_all)
        else
          @select_group_id = params[:group_id]
        end
        # グループ検索用
        @search_group_users = User.joins(:groups).where(users_groups_users_join: { group_id: params[:group_id]}) if params[:group_id].present?
        group_user_id_list = []
        if @search_group_users.blank?
        else
          @search_group_users.each do |group_user|
            group_user_id_list << group_user.id
          end
        end

        if params[:registration_date].blank?
          if params[:group_id].blank? || params[:group_id] == l(:select_all)
            @destination_bbs = RedmineDestinationBbsModel.all
          else
            @destination_bbs = RedmineDestinationBbsModel.where(user_id: group_user_id_list)
          end
        else
          if params[:group_id].blank? || params[:group_id] == l(:select_all)
            @destination_bbs = RedmineDestinationBbsModel.where(registration_date: params[:registration_date])
          else
            @destination_bbs = RedmineDestinationBbsModel.where(registration_date: params[:registration_date], user_id: group_user_id_list)
          end
        end
        # グループユーザー一覧表示用
        if @search_group_users.blank?
          @search_group_users_list = ''
        else
          @search_group_users_list = get_group_user_list(@destination_bbs)
        end
        send_data render_to_string, filename: "destination_bbs.csv", type: :csv
      end
      format.api do
        @users_list = User.select('id').where.not type: ["GroupAnonymous", "GroupNonMember", "AnonymousUser", "Group"], status: [0, 2, 3]
        if params[:registration_date].blank?
          @destination_bbs = RedmineDestinationBbsModel.where(user_id: @users_list)
        else
          @destination_bbs = RedmineDestinationBbsModel.where(registration_date: params[:registration_date])
        end
      end
    end
  end

  def create
    @destination_bbs = RedmineDestinationBbsModel.new(params[:destination_bbs])
    @destination_bbs.user_id = params[:user_id]
    @destination_bbs.destination = params[:destination]
    # 年休ボタン押下時のみ当日以外の登録可能
    if params[:destination] == l(:button_holiday)
      @destination_bbs.registration_date = params[:registration_date]
    else
      @destination_bbs.registration_date = Date.today
      @destination_bbs.start_time = params[:start_time]
    end
    
    if @destination_bbs.save
      flash[:notice] = l(:notice_successful_create)
      move_to_index
    end
  end

  def update
    # コメント確認
    if params[:comment].present?
      @destination_bbs = RedmineDestinationBbsModel.where(user_id: params[:user_id], registration_date: params[:registration_date])
      # コメント更新時はコメントのみ更新
      if @destination_bbs.update(comment: params[:comment])
        flash[:notice] = l(:notice_successful_update)
        move_to_index
      end
    else
      # 行先確認(年休の場合当日以外も登録可)
      if params[:destination] == l(:button_holiday)
        @destination_bbs = RedmineDestinationBbsModel.where(user_id: params[:user_id], registration_date: params[:registration_date])
        destination_bbs = RedmineDestinationBbsModel.where(user_id: params[:user_id], registration_date: params[:registration_date]).first
      else
        # 年休以外の場合は当日のレコードのみ更新可
        @destination_bbs = RedmineDestinationBbsModel.where(user_id: params[:user_id], registration_date: Date.today)
        destination_bbs = RedmineDestinationBbsModel.where(user_id: params[:user_id], registration_date: Date.today).first
      end

      # コメント空欄時に更新ボタンを押した場合は何も更新しない
      if params[:destination].blank?
        move_to_index
      else
        # 退勤ボタンを押した時のみ終了時刻を更新
        if params[:end_time].present?
          if @destination_bbs.update(end_time: params[:end_time])
            flash[:notice] = l(:notice_successful_update)
            move_to_index
          end
        elsif destination_bbs.start_time.blank? && params[:destination] != l(:button_holiday)
          if @destination_bbs.update(destination: params[:destination], start_time: Time.zone.now)
            flash[:notice] = l(:notice_successful_update)
            move_to_index
          end
        else
          if @destination_bbs.update(destination: params[:destination])
            flash[:notice] = l(:notice_successful_update)
            move_to_index
          end
        end
      end
    end
  end

  # 週間情報表示用
  def report
    # 検索(日付・グループ)
    @search_params = destination_bbs_search_params
    # 週間情報取得
    @beginning_of_week = Date.today.beginning_of_week
    @next_week = Date.today.next_week(day= :monday)

    # グループ名取得
    scope = Group.sorted.where(type: 'Group')
    @groups = scope.to_a

    # 在勤地情報取得
    @custom_values = get_working_in_place

    # 曜日配列
    @weekday_list = %w((日) (月) (火) (水) (木) (金) (土))

    respond_to do |format|
      format.html do
        # グループすべて選択時
        if @search_params[:group_id].blank? || @search_params[:group_id] == l(:select_all)
          group_id_list = []
          @groups.each do |g|
            group_id_list << g.id
          end
          @search_params[:group_id] = group_id_list
          @select_group_id = l(:select_all)
        else
          @select_group_id = @search_params[:group_id]
        end
        # グループ検索用
        @search_group_users = User.joins(:groups).where(users_groups_users_join: { group_id: @search_params[:group_id] }) if @search_params[:group_id].present?
        # グループユーザー一覧表示用
        group_user_id_list = []
        if @search_group_users.blank?
        else
          @search_group_users.each do |group_user|
            group_user_id_list << group_user.id
          end
        end
        @destination_bbs_to_report = RedmineDestinationBbsModel.where(user_id: group_user_id_list)
      end
      format.csv do
        # グループすべて選択時
        if params[:group_id].blank? || params[:group_id] == l(:select_all)
          group_id_list = []
          @groups.each do |g|
            group_id_list << g.id
          end
          params[:group_id] = group_id_list
          @select_group_id = l(:select_all)
        else
          @select_group_id = params[:group_id]
        end
        # グループ検索用
        @search_group_users = User.joins(:groups).where(users_groups_users_join: { group_id: params[:group_id] }) if params[:group_id].present?
        # グループユーザー一覧表示用
        group_user_id_list = []
        if @search_group_users.blank?
        else
          @search_group_users.each do |group_user|
            group_user_id_list << group_user.id
          end
        end
          @destination_bbs_to_report = RedmineDestinationBbsModel.where(user_id: group_user_id_list)
          send_data render_to_string, filename: "destination_weekly_report.csv", type: :csv
        end
      end
  end


  private

  # indexリダイレクト用
  def move_to_index
    redirect_back(fallback_location: {:controller => 'redmine_destination_bbs', :action => 'index'})
  end

  # グループユーザー一覧表示用
  def get_group_user_list(base_model)
    query = base_model.select(:user_id)
    @search_group_users.where.not id: query, type: ["GroupAnonymous", "GroupNonMember", "AnonymousUser", "Group"], status: [0, 2, 3]
  end

  # 在勤地情報取得
  def get_working_in_place
    custom_field_id = CustomField.where(name: "在勤地").select('id')
    CustomValue.where(customized_type: 'Principal', custom_field_id: custom_field_id).select('customized_id', 'value')
  end

  # 日付指定時の検索用関数
  def destination_bbs_search_params
    params.fetch(:search, {}).permit(:registration_date, :group_id)
  end

end
