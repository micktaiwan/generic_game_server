module Utils

  def log(text)
    puts "#{Time.now.strftime("%a %d-%b %H:%M:%S")} - #{text}"
  end

end

