# Controller to deal witih people

class PeopleController < ApplicationController

  def complete_people
    # Parameters: {"timestamp"=>"1235989842305", "q"=>"ab", "limit"=>"150"}
    query = params[:q].downcase
    limit = params[:limit].to_i

    render :text => Person.search(query)[0..limit].map { |person| person.fullname}.join("\n")
  end
  
end
