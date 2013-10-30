require 'CSV'
require_relative 'youtrack'

project_id = 'pwi'

i = Youtrack.new
i.authenticate '2rk', '2rk'

first = true
parent_issue = nil
parent_feature = ""
epic_hide = false

CSV.foreach('import.csv') do |row|
  unless first
    epic = row[0]
    summary = row[1]
    hours = row[2]
    hide = row[3]
    task_type = 'task' if row[4]

    if epic
      parent_issue = i.create_ticket project_id, private: hide, type: 'epic', estimation: hours, summary: epic
      parent_feature = epic
      epic_hide = hide
    elsif summary
      i.create_ticket project_id, private: hide || epic_hide, type: task_type, estimation: hours, summary: "#{summary} [#{parent_feature}]", subtask_of: parent_issue
    end
  end
  first = false

end

