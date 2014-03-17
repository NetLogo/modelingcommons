# -*-ruby-*-

namespace :nlcommons do

  desc 'Create an adjacency matrix for people/subject overlap'
  task :person_interest_adj_matrix => :environment do 

    shared_interests = Hash.new { |h, k| h[k] = Hash.new(0) }

    Node.find_by_sql("SELECT person1_id, person2_id, proportion_shared
                        FROM shared_interests_view").each do |shared_result| 

      person1_id = shared_result.person1_id.to_i
      person2_id = shared_result.person2_id.to_i
      proportion_shared = shared_result.proportion_shared.to_f

      shared_interests[person1_id][person2_id] = proportion_shared
      shared_interests[person2_id][person1_id] = proportion_shared
    end

    person_ids = Person.order("id ASC").all.map {|p| p.id}

    output = [ ]

    first_row = [' '] + person_ids
    output << first_row.join("\t")

    person_ids.each do |p1|
      row = [p1]
      person_ids.each do |p2|
        row << shared_interests[p1][p2]
      end
      output << row.join("\t")
    end

    puts output.join("\n")
  end
end
