# -*-ruby-*-
def get_network(network_type)

  STDERR.puts "Finding networks of #{network_type}"

  output = [ ]
  output_filename = "/tmp/#{network_type}-network.data"

  Person.all.each do |person|
    begin
      STDERR.puts "\tPerson '#{person.id}'"
      yield person, output
    rescue Exception => e
      STDERR.puts "Problem... next!"
      STDERR.puts "\tException class: #{e.class}"
      STDERR.puts "\tException message: #{e.message}"
    end
  end
  
  File.open(output_filename, 'w') {  |f| f.puts output.join("\n") }
end

namespace :network do

  desc 'Generate data for authoring collaboration'
  task :authoring => :environment do

    get_network 'authoring' do |person, output|
      person.nodes.each do |node|
        STDERR.puts "\t\t\tAuthor of '#{node.id}'"
        output << ["P#{person.id}", "N#{node.id}", 'authoring'].join("\t")
      end
    end
  end

  desc 'Generate data for attachment collaboration'
  task :attaching => :environment do

    get_network 'attaching' do |person, output|
      person.attachments.each do |attachment|
        STDERR.puts "\t\t\tAttached to '#{node.id}'"
        output << ["P#{person.id}", "N#{attachment.node_id}", 'attaching'].join("\t")
      end
    end
  end

  desc 'Generate data for recommendation collaboration'
  task :recommending => :environment do

    get_network 'recommending' do |person, output|
      person.recommendations.each do |recommendation|
        STDERR.puts "\t\t\tRecommended '#{recommendation.node.id}'"
        output << ["P#{person.id}", "N#{recommendation.node.id}", 'recommending'].join("\t")
      end
    end
  end

  desc 'Generate data for downloading'
  task :downloading => :environment do

    get_network 'downloading' do |person, output|
      person.downloaded_nodes.each do |node|
        STDERR.puts "\t\t\tDownloaded '#{node.id}'"
        output << ["P#{person.id}", "N#{node.id}", 'downloading'].join("\t")
      end
    end
  end

  desc 'Generate data for non-question posting'
  task :non_question_posting => :environment do

    get_network 'non-question posting' do |person, output|
      person.non_questions.each do |posting|
        next if posting.deleted_at
        STDERR.puts "\t\t\tAsked about '#{posting.node.id}'"
        output << ["P#{person.id}", "N#{posting.node.id}", 'non-question posting'].join("\t")
      end
    end
  end

  desc 'Generate data for answered question posting'
  task :answered_question_posting => :environment do

    get_network 'answered question posting' do |person, output|
      person.questions.each do |posting|
        next if posting.deleted_at
        next unless posting.answered_at
        STDERR.puts "\t\t\tAsked an answered question about '#{posting.node.id}'"
        output << ["P#{person.id}", "N#{posting.node.id}", 'answered question posting'].join("\t")
      end
    end
  end

  desc 'Generate data for unanswered question posting'
  task :unanswered_question_posting => :environment do

    get_network 'unanswered question posting' do |person, output|
      person.questions.each do |posting|
        next if posting.deleted_at
        next if posting.answered_at
        STDERR.puts "\t\t\tAsked an unanswered question about '#{posting.node.id}'"
        output << ["P#{person.id}", "N#{posting.node.id}", 'unanswered question posting'].join("\t")
      end
    end
  end

  desc "Generate data for downloading a user's models"
  task :download_user_models => :environment do

    get_network 'download_user_models' do |person, output|
      person.questions.each do |posting|
        STDERR.puts "\t\t\tAsked an unanswered question about '#{posting.node.id}'"
        output << ["P#{person.id}", "N#{posting.node.id}", 'download_user_models'].join("\t")
      end
    end
  end

  desc "Generate data for forking a user's models"
  task :forking => :environment do

    get_network 'forking' do |person, output|
      person.nodes.each do |node|
        next unless node.parent
        STDERR.puts "\t\t\tForked model '#{node.parent_id}'"
        output << ["P#{person.id}", "N#{node.parent_id}", 'forking'].join("\t")
      end
    end
  end

  desc "Generate data for tagging a model"
  task :tagging => :environment do

    get_network 'tagging' do |person, output|
      person.tagged_nodes.each do |node|
        STDERR.puts "\t\t\tTagged model '#{node.id}'"
        output << ["P#{person.id}", "N#{node.id}", 'tagging'].join("\t")
      end
    end
  end

  desc "Viewed a model"
  task :viewing => :environment do

    get_network 'viewing' do |person, output|
      person.viewed_nodes.each do |node|
        STDERR.puts "\t\t\tViewed model '#{node.id}'"
        output << ["P#{person.id}", "N#{node.id}", 'viewing'].join("\t")
      end
    end
  end

  desc "Downloaded all of a user's models"
  task :user_download_all => :environment do

    get_network 'user_download_all' do |person, output|
      person.user_model_downloads.each do |node|
        STDERR.puts "\t\t\tDownloaded model '#{node.id}' as part of a full-user download"
        output << ["P#{person.id}", "N#{node.id}", 'user_download_all'].join("\t")
      end
    end
  end

  desc "Downloaded all of a tag's models"
  task :tag_download_all => :environment do

    get_network 'tag_download_all' do |person, output|
      person.tag_model_downloads.each do |node|
        STDERR.puts "\t\t\tDownloaded model '#{node.id}' as part of a full-tag download"
        output << ["P#{person.id}", "N#{node.id}", 'tag_download_all'].join("\t")
      end
    end
  end

  desc "Downloaded all of a project's models"
  task :project_download_all => :environment do

    get_network 'project_download_all' do |person, output|
      person.project_model_downloads.each do |node|
        STDERR.puts "\t\t\tDownloaded model '#{node.id}' as part of a full-project download"
        output << ["P#{person.id}", "N#{node.id}", 'project_download_all'].join("\t")
      end
    end
  end


end
