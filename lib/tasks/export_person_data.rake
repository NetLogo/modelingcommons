# -*-ruby-*-

namespace :nlcommons do

  desc 'Export personal data'
  task :export_people => :environment do 

    STDERR.puts "Exporting person data"

    output = [ ]

    header_line = %w(id email_address first_name last_name registered_at updated_at has_avatar sex birthdate country_name number_of_models number_of_postings number_of_questions number_of_tagged_models number_of_recommendations number_of_projects number_of_model_versions number_of_model_attachments number_of_collaborations)
    output << header_line.join("\t")

    output_filename = "/tmp/person.data"

    Person.all.each do |person|
      person_output = [ ]

      STDERR.puts "\tPerson '#{person.id}'"
      person_output << person.id
      person_output << person.email_address
      person_output << person.first_name
      person_output << person.last_name
      person_output << person.created_at
      person_output << person.updated_at
      person_output << person.avatar_file_name.present?
      person_output << person.sex
      person_output << person.birthdate
      person_output << person.country_name
      person_output << person.nodes.count
      person_output << person.postings.count
      person_output << person.questions.count
      person_output << person.tagged_nodes.count
      person_output << person.recommendations.count
      person_output << person.projects.count
      person_output << person.versions.count
      person_output << person.attachments.count
      person_output << person.collaborations.count

      output << person_output.join("\t")
    end
    
    File.open(output_filename, 'w') {  |f| f.puts output.join("\n") }
  end
end
