class CreateAttendanceLocations < ActiveRecord::Migration[5.2]
    def change
        if !table_exists?(:attendance_locations)
            create_table :attendance_locations do |t|
                t.text :location_list
            end
        end
    end
end