require 'pry'

namespace :development do
  task :console do
    binding.pry
  end
end

