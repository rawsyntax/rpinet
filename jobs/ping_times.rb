#require 'active_support/core_ext'

pings = Hash.new({ value: 0 })

SCHEDULER.every '20s' do

  ['google.com', 'netflix.com', 'speedtest.net', 'comcast.net', 'unreach0123.com'].each do |site|
    val  = `ping -c 1 -t 5 #{site}`
    if !val.empty?
      time = val.split('\n').last.split('=').last.split('/')[1].to_i.to_s + 'ms'

      pings[site] = {label: site, value: time}
    else
      send_event('ping_failures',
                 {items: [{label: site, value: 1}]})
    end
  end

  send_event('ping_times', { items: pings.values })
end
