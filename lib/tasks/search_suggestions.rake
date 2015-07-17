namespace :search_suggestions do
  desc "Generate search suggestions from researchers"
  task :index => :environment do
    SearchSuggestion.index_researchers
  end
end
