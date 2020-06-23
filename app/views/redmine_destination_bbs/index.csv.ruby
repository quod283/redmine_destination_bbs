require 'csv'

# 文字化け対策でBOM付きUTF-8で出力する
bom = "\uFEFF"
CSV.generate(bom) do |csv|
    column_names = %w(名前 行先 開始時刻 終了時刻 在勤地 コメント 日付)
    csv << column_names
    @destination_bbs.each do |destination_bbs|
        if destination_bbs.start_time.present?
            start_time = destination_bbs.start_time.to_time.to_s(:time)
        else
            start_time = ''
        end
        if destination_bbs.end_time.present?
            end_time = destination_bbs.end_time.to_time.to_s(:time)
        else
            end_time = ''
        end
        column_values = [
            @users.find(destination_bbs.user_id),
            destination_bbs.destination,
            start_time,
            end_time,
            @custom_values.where(customized_id: destination_bbs.user_id).select('value').first,
            destination_bbs.comment,
            destination_bbs.registration_date
        ]
        csv << column_values
    end
    @search_group_users_list_distinct.each do |group_user|
        column_values = [
            group_user,
            '',
            '',
            '',
            @custom_values.where(customized_id: group_user.id).select('value').first,
            '',
            ''
        ]
        csv << column_values
    end
end