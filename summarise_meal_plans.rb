require 'nokogiri'
require 'pry'

DAYS_OF_WEEK_REGEX="(?:Mon|Tues?|Wed(?:ne)s?|Thurs?|Fri|Sat(?:ur)?|Sun)(?:day)?"

THINGS_THAT_ARENT_MEALS=[
  "garlic",
  "milk",
  "coriander",
  "limes",
  "pepper",
  "avocado",
  "red onion",
  "sour cream",
  "onion",
  "tomato",
  "muesli",
  "jalapenos",
  "beans",
  "wraps",
  "eggs",
  "lunches",
  "bobi and",
  "potatoes",
  "courgette",
  "cheddar?",
  "beef",
  "taco shells",
  "stuff to",
  "baked beans",
  "new years"
]

def named_as_meal_plan(filename)
  filename.match("^Notes[0-9-]+.txt$")
end

meals = []

Dir.chdir('icloud_notes_export') do
  Dir.glob('*').select do |filename| 
    # matches = named_as_meal_plan(filename) ? '✅' : '❌'
    # puts "#{matches} #{filename}"
    File.file?(filename) && named_as_meal_plan(filename)
  end.each do |filename|
    # puts "👀 #{filename}"
    doc =  Nokogiri::HTML5(File.open(filename)) 
    
    lists = doc.xpath("//ol|//ul")

    lists.each do |list|
      list.xpath("li").each do |list_item|
        # puts list_item.text
        plan_with_day = list_item.text.match("(#{DAYS_OF_WEEK_REGEX}):? (.*)")

        if plan_with_day
          plan = plan_with_day.captures.map(&:lstrip).map(&:chomp).last

          meals << plan unless plan.empty?
        else
          plan = list_item.text.chomp

          # Skip over lines that start with a number
          # these are ingredients lists
          next if plan.start_with?(/\d+/)

          meals << plan unless plan.empty?
        end
        # binding.pry
      end
    end

    puts "🚨 No list found in #{filename}" if lists.empty?

    # binding.pry

    # Print out errors (we normally see none)
    unless doc.errors.empty?
      puts "Errors parsing #{filename}:\n"
      doc.errors.each do |error|
        puts error.inspect
      end
      puts "-----"
    end
  end
end

# Works with lower case everything, for ease
meals = meals.map(&:downcase)

# Clean out spurious meals
meals = meals.reject do |meal|
  THINGS_THAT_ARENT_MEALS.include?(meal.downcase) || 
    meal.start_with?("?") || 
    meal.downcase.start_with?("leftover") || meal.downcase.start_with?("left over") ||
    meal.downcase.start_with?("clear")
end

# Massage things to clean the data
meals = meals.map do |meal|
  meal.gsub!(',', '')

  meal = "Macaroni cheese" if meal.start_with?("mac'n") || meal.start_with?("mac n") || meal.start_with?("macaroni") || meal.start_with?("mac &") || meal.start_with?("crab mac")
  meal
end

# sorted_by_popularity = meals.sort.compact.tally.sort_by {|a,b| -b}

# Add casing back in so it's easy to read
meals = meals.map(&:capitalize)

group_by_prefix = meals.group_by{|a| a.split.first(2).join(" ")}
counts_by_prefix = group_by_prefix.map{|prefix, list_of_meals | [prefix, list_of_meals.count]}.to_h
sorted_by_prefix_popularity = counts_by_prefix.sort_by {|a,b| -b}.to_h

# binding.pry

pp sorted_by_prefix_popularity