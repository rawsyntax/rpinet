require 'active_support/all'

pings         = Hash.new({ value: 0 })
ping_failures = Hash.new({ value: 0 })

SCHEDULER.every '30s' do

  ['google.com', 'netflix.com', 'speedtest.net', 'comcast.net'].each do |site|
    val  = `ping -c 1 #{site} 2>&1`
    time = val.split('\n').last.split('=').last.split('/')[1].to_i.to_s + 'ms'

    if time == "0ms"
      ping_failures[Time.now.to_i] =
        {label: site, value: Time.now.strftime('%I:%M%P')}

      ping_failures.keys.select{ |k| k < 1.day.ago.to_i }
        .map {|k| ping_failures.delete(k) }

      File.open('failures.log', 'a') do |f|
        f.write("#{Time.now.localtime.to_s} -- #{site}\n")
        f.write("#{val}\n\n")
      end

    else
      pings[site] = {label: site, value: time}
    end
  end

  send_event('ping_failures', { items: ping_failures.values })
  send_event('ping_times', { items: pings.values })
end
