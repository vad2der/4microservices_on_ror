#!/usr/bin/env ruby
class EntriesCheck
    def self.deliver_entries
        undelivered = Entry.where(delivered_to_parser: false).all
        undelivered.each {|ud|
            ud.send_to_parser()
        }
        undelivered = Entry.where(delivered_to_parser: nil).all
        undelivered.each {|ud|
            ud.send_to_parser()
        }
    end
end