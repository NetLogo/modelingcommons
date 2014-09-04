# -*-ruby-*-

namespace :nlcommons do

  desc 'Create an adjacency matrix for people/subject overlap'
  task :person_interest_adj_matrix => :environment do 

    uri = Person.find_by_email_address('uri@northwestern.edu')

    individual_interests = { }
    threshhold = 0.3

    # Load in people and interests
    Person.find_by_sql("SELECT person_id, 
                               array_to_string(tag_ids, ',') as tag_ids,
                               array_to_string(node_ids, ',') as node_ids
                          FROM Person_Interests
                      ORDER BY person_id").each_with_index do |one_person_interest, index|

      person_id = one_person_interest['person_id'].to_i
      tag_ids = one_person_interest['tag_ids'].split(',').map {|i| i.to_i}.sort
      node_ids = one_person_interest['node_ids'].split(',').map {|i| i.to_i}.sort

      # STDERR.puts "[#{index}] Person ID '#{person_id}' - '#{person_id.class}', tag_ids '#{tag_ids.size}', node_ids '#{node_ids.size}'"

      tag_counts = [ ]

      tag_ids.map! do |tag_id|
        tag_counts[tag_id] = tag_counts[tag_id].to_i + 1
        "#{tag_id}-#{tag_counts[tag_id]}"
      end

      individual_interests[person_id] = tag_ids
    end

    shared_interests = Hash.new { |h, k| h[k] = Hash.new(0) }

    individual_interests.each do |person1_id, person1_tag_ids|
      individual_interests.each do |person2_id, person2_tag_ids|

        # STDERR.puts "Checking '#{person1_id.inspect}' and '#{person2_id.inspect}'"

        if person1_id == person2_id
          shared_interests[person1_id][person2_id] = 1
          # STDERR.puts "\tPerson '#{person1_id}' with himself..."
        end

        # If we have already done this pair (person1_id / person2_id), then skip it
        next if shared_interests[person1_id].has_key?(person2_id)

        # Get nodes on which they collaborated
        collaboration_node_ids = Node.find_by_sql(["SELECT node_id FROM Collaborations WHERE person_id = ? 
                                                    INTERSECT
                                                    SELECT node_id FROM Collaborations WHERE person_id = ?",                                                   person1_id,
                                                   person2_id]).map {|n| n.node_id.to_i}

        # STDERR.puts "\tPerson '#{person1_id}' and '#{person2_id}' collaborated on: '#{collaboration_node_ids.inspect}'"
        # STDERR.puts "\tPerson1 has '#{person1_tag_ids.size}' interests"
        # STDERR.puts "\tPerson2 has '#{person2_tag_ids.size}' interests"

        # STDERR.puts "\tRemoving tags from each of their collaborations"
        Node.find(collaboration_node_ids).each do |n|

          tag_counts = [ ]

          collaboration_tag_ids = n.tags.map {|n| n.id}

          collaboration_tag_ids.map! do |tag_id|
            tag_counts[tag_id] = tag_counts[tag_id].to_i + 1
            "#{tag_id}-#{tag_counts[tag_id]}"
          end

          # STDERR.puts "\t\tCollaboration tag ids for node '#{n.id}': '#{collaboration_tag_ids.inspect}'"

          person1_tag_ids = person1_tag_ids - collaboration_tag_ids
          person2_tag_ids = person2_tag_ids - collaboration_tag_ids
        end

        # STDERR.puts "\tPerson1 now has '#{person1_tag_ids.size}' interests"
        # STDERR.puts "\tPerson2 now has '#{person2_tag_ids.size}' interests"

        intersection = person1_tag_ids & person2_tag_ids
        # STDERR.puts "\tIntersection has '#{intersection.size}' elements"
        union = person1_tag_ids | person2_tag_ids

        # STDERR.puts "\tUnion has '#{union.size}' elements"

        jaccard_similarity = (intersection.size.to_f / union.size)
        binary_jaccard_similarity = (jaccard_similarity >= threshhold) ? 1 : 0
        shared_interests[person1_id][person2_id] = binary_jaccard_similarity
        shared_interests[person2_id][person1_id] = binary_jaccard_similarity

        # STDERR.puts "\tJaccard similarity for is '#{jaccard_similarity}', binary version is '#{binary_jaccard_similarity}'"

      end
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
