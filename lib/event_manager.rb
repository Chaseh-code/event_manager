require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'



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
    phone_num = phone
end

content = CSV.open('event_attendees.csv', headers:true, header_converters: :symbol)
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

content.each do |line|
    #next if index == 0
    id = line[0]
    name = line[:first_name]
    phone = line[:homephone]
    puts "phone " + phone
    zipcode = clean_zipcode(line[:zipcode])
    legislators = legislators_by_zipcode(zipcode)
    form_letter = erb_template.result(binding)
    save_thank_you_letter(id,form_letter)
    #personal_letter = template_letter.gsub('FIRST_NAME', name)
    #personal_letter.gsub!('LEGISLATORS', legislators)

    #puts form_letter
    #puts "\n#{name} #{zipcode} #{legislators}\n"
end


