require 'csv'

# 文字化け対策でBOM付きUTF-8で出力する
bom = "\uFEFF"
CSV.generate(bom) do |csv|
    column_names = %w(名前 行先 開始時刻 終了時刻 在勤地 コメント)
    csv << column_names
    @destination_bbs.each do |destination_bbs|
        if destination_bbs.start_time.present?
            destination_bbs.start_time = destination_bbs.start_time.to_time.to_s(:time)
        else
            destination_bbs.start_time = ''
        end
        if destination_bbs.end_time.present?
            destination_bbs.end_time = destination_bbs.end_time.to_time.to_s(:time)
        else
            destination_bbs.end_time = ''
        end
        column_values = [
            @users.find(destination_bbs.user_id),
            destination_bbs.destination,
            destination_bbs.start_time,
            destination_bbs.end_time,
            @custom_values.where(customized_id: destination_bbs.user_id).select('value').first,
            destination_bbs.comment
        ]
        csv << column_values
    end
end