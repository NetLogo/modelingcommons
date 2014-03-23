# -*-ruby-*-

namespace :nlcommons do

  desc 'Create an adjacency matrix for people/subject overlap'
  task :person_interest_adj_matrix => :environment do 

    threshhold = 0.5
    shared_interests = Hash.new { |h, k| h[k] = Hash.new(0) }

    Node.find_by_sql("SELECT person1_id, person2_id, jaccard_similarity
                        FROM shared_interests_view").each do |shared_result| 

      person1_id = shared_result.person1_id.to_i
      person2_id = shared_result.person2_id.to_i
      jaccard_similarity = shared_result.jaccard_similarity.to_f

      if jaccard_similarity >= 0.5
        binary_jaccard_similarity = 1
      else
        binary_jaccard_similarity = 0
      end

      shared_interests[person1_id][person2_id] = binary_jaccard_similarity
      shared_interests[person2_id][person1_id] = binary_jaccard_similarity
    end

    person_ids = Person.order("id ASC").all.map {|p| p.id}

    output = [ ]

    # removed this row for bpnet
    # first_row = [' '] + person_ids
    # output << first_row.join("\t")

    person_ids.each do |p1|
      # removed this row for bpnet
      # row = [p1]
      row = []
      person_ids.each do |p2|
        row << shared_interests[p1][p2]
      end
      output << row.join("\t")
    end

    puts output.join("\n")
  end
end
