
require 'pp'

#############
# Variables #
#############

########
# Main #
########

# Create an array of a list of lua files
list_of_files = Dir['**/*.{lua,LUA}']

# Loop over the files
list_of_files.each do |e|

    # Does the file have a citizen thread?
    number_of_citizen_threads = File.foreach(e).grep(/Citizen.CreateThread/).count

    # We're going to skip the file if it has no Citizen Threads
    next if number_of_citizen_threads == 0

    # Create an empty array.
    file_array = []

    # Open the file and put every line into an array. We're gonna do some funky things with indexes, which is why
    # we are not just looping over the file.
    File.readlines(e).each do |line|
        file_array << line
    end

    file_array.each_with_index do |line,i|

        if line =~ /Citizen.CreateThread/
            # If we have found a citizen thread, stop looping, and now loop based on the proximity to this line.
            # I.E if we find this on line 35. We'll just assume that it's line 34 (index starts at 0), and we'll just 
            # increment the array until we find the outer most end)


            waits = []
            found = nil
            start = i
            counter = 1

            until found == true do
                break if counter > 2000
                next_line = file_array[counter]

                # Does the line contain a wait?
                if next_line =~ /Citizen.Wait|Wait\(/
                    ms = next_line.scan(/\d+/)
                    if ms != []
                        waits << ms
                    end
                end

                if next_line == "end)"
                    found = true
                end

                counter = counter + 1
            end
            
            crit = true
            waits.flatten.each do |x|
                if x.to_i > 0 then
                    crit = false
                end
            end

            if crit == true
                puts "#{e} has a citizen thread with no waits in it"
            end

        end


    end

end
