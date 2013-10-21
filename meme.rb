require 'CSV'
require_relative 'youtrack'

i = Youtrack.new
i.authenticate 'test', 'test'
#p i.create_ticket 'test', summary: 'hellomeme'
#
#exit

first = true
parent_issue = nil
parent_feature = ""
CSV.foreach('import.csv') do |row|
  unless first
    feature = row[0]
    summary = row[1]
    hours = row[2]
    hide = row[3]
    task_type = 'task' if row[4]

    if feature
      parent_issue = i.create_ticket 'test', private: hide, type: task_type, estimation: hours, summary: feature
      parent_feature = feature
    elsif summary
      i.create_ticket 'test', private: hide, type: task_type, estimation: hours, summary: "#{summary} [#{parent_feature}]", subtask_of: parent_issue
    end

  end
  first = false

end

