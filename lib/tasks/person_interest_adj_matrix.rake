# -*-ruby-*-

namespace :nlcommons do

  desc 'Create an adjacency matrix for people/subject overlap'
  task :person_interest_adj_matrix => :environment do 

    uri = Person.find_by_email_address('uri@northwestern.edu')

    threshhold = 0.5
    shared_interests = Hash.new { |h, k| h[k] = Hash.new(0) }

    Node.find_by_sql("SELECT person1_id, person2_id, jaccard_similarity
                        FROM shared_interests_view").each do |shared_result| 

      person1_id = shared_result.person1_id.to_i
      person2_id = shared_result.person2_id.to_i

      # Ignore Uri
      next if person1_id == uri.id or person2_id == uri.id

      jaccard_similarity = shared_result.jaccard_similarity.to_f

      binary_jaccard_similarity = (jaccard_similarity >= 0.5) ? 1 : 0

      shared_interests[person1_id][person2_id] = binary_jaccard_similarity
      shared_interests[person2_id][person1_id] = binary_jaccard_similarity
    end

    sna_people = Person.sna_people

    output = [ ]

    sna_people.each do |p1|
      row = []
      sna_people.each do |p2|
        row << shared_interests[p1.id][p2.id]
      end
      output << row.join("\t")
    end

    puts output.join("\n")
  end
end
