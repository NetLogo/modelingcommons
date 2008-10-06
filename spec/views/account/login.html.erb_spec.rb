require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe '/account/index.html.erb' do
  it 'should show the login page' do
    render '/account/index', :layout => 'application'
    response.should have_tag('h1')
    response.should have_tag('form#navbar-search-form') do
      response.should have_tag('input#search_term_search_term')
    end
  end
end
