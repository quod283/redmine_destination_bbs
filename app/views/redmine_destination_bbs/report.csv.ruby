require 'csv'

# 文字化け対策でBOM付きUTF-8で出力する
bom = "\uFEFF"
CSV.generate(bom) do |csv|
    # ヘッダ部分
    column_names = %w(名前 在勤地)
    (@beginning_of_week...@next_week).each do |date|
        column_names << date.strftime('%m-%d') + @weekday_list[date.wday]
    end
    csv << column_names
    # 出力データ
    @search_group_users_distinct.each do |group_user|
        column_values =[
            group_user,
            @custom_values.where(customized_id: group_user.id).select('value').first
        ]
        (@beginning_of_week...@next_week).each do |date|
            @destination_bbs_to_report.where(user_id: group_user.id, registration_date: date).each do |record|
                column_values << record.destination
            end
        end
        csv << column_values
    end
end