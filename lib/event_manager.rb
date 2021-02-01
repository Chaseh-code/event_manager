require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'


puts 'Event Manager Initialized!'

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,'0')[0..4]
end

def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials
        #legislators = legislators.officials
        #legislator_names = legislators.map(&:name)
        #legislator_string = legislator_names.join(", ")
    rescue 
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end

def save_thank_you_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exists?('output')
    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end

def clean_phone(phone)
    phone.gsub!(/[^\d]/,'')
    if phone.length == 10
        phone
    elsif phone.length == 11 && phone[0] == "1"
        phone[1..10]
    else
        "Invalid number. Please update to a valid phone number if you would like us to contact you that way."
    end
end

content = CSV.open('event_attendees.csv', headers:true, header_converters: :symbol)
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

content.each do |line|
    #next if index == 0
    id = line[0]
    name = line[:first_name]
    phone = clean_phone(line[:homephone])
    reg_date = DateTime.strptime(line[:regdate], '%m/%d/%y %k:%M')
    time = reg_date.strftime("Registered on %m/%d/%y")
    day = reg_date.wday
    puts name + "'s phone # is: " + phone
    puts time
    case day
        when 0
            then weekday = "Sunday"
        when 1
            then weekday = "Monday"
        when 2
            then weekday = "Tuesday"
        when 3
            then weekday = "Wednesday"
        when 4
            then weekday = "Thursday"
        when 5
            then weekday = "Friday"
        when 6
            then weekday = "Saturday"
        else
             weekday = "Invalid Day!"
    end
    puts "Their registration day was on: " + weekday
    puts "Time Registered at " + reg_date.hour.to_s 
    puts 
    zipcode = clean_zipcode(line[:zipcode])
    legislators = legislators_by_zipcode(zipcode)
    form_letter = erb_template.result(binding)
    save_thank_you_letter(id,form_letter)
    #personal_letter = template_letter.gsub('FIRST_NAME', name)
    #personal_letter.gsub!('LEGISLATORS', legislators)

    #puts form_letter
    #puts "\n#{name} #{zipcode} #{legislators}\n"
end


