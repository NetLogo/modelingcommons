require 'resolv.rb'
require 'net/telnet.rb'
class EmailValidation
  
  EMAIL_REGEX = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  
  def self.valid_email?(address, level = 2, pass_on_unable_to_verify = true, from = "")
    vaf = valid_address_format?(address)
    vms, mail_server = valid_mail_server?(address) if vaf and level > 1
    #--
    #tmp_a = valid_mail_server?(address) if vaf and level > 1
    #vms = tmp_a[0] if vaf and level > 1
    #mail_server = tmp_a[1] if vaf and level > 1
    #--
    vea = valid_email_account?(address, mail_server, pass_on_unable_to_verify, from) if vms and level > 2
    
    return true if (vaf and level == 1) or (vms and level == 2) or (vea and level == 3)
    false
  end
  
  def self.valid_address_format?(address)
    address =~ EMAIL_REGEX
  end
  
  def self.valid_mail_server?(address)
    tmp_a = Array.new
    domain = address.split('@')[1]
    Resolv::DNS.open do |dns|
      #--
      #ress = dns.getresources "www.ruby-lang.org", Resolv::DNS::Resource::IN::A
      #p ress.map { |r| r.address }
      ress = dns.getresources domain, Resolv::DNS::Resource::IN::MX
      #p ress.map { |r| [r.exchange.to_s, r.preference] }
      #++
      tmp_a = ress.map { |r| [r.exchange.to_s, r.preference] }
    end
    return tmp_a.length > 0, (tmp_a[0].class.name == Array ? tmp_a[0][0] : nil)
  end
  
  def self.valid_email_account?(address, mail_server, pass_on_unable_to_verify = true, from = "")
    continue = false
    unable_to_verify = false
    debug = false
    tmp_a = mail_server.split(".")
    short_server_name = tmp_a.slice!(0, tmp_a.length - 1).join(".")

    server = Net::Telnet::new("Host" => mail_server, "Port" => 25, "Prompt" => /250|550|221/)
    print "Connected\n" if debug and server

    continue = server.cmd("helo " + short_server_name).to_s if server
    print "helo " + short_server_name + " " + continue.to_s + "\n" if debug

    continue = server.cmd("mail from:<" + from + ">").to_s.include?("250") if continue
    print "mail from:<" + from + "> " + continue.to_s + "\n" if debug


    tmp_s = server.cmd("rcpt to:<" + address + ">").to_s if continue
    print "rcpt to:<" + address + ">\n" + tmp_s if debug

    continue = tmp_s.include?("250") ? true : false
    print continue.to_s + "\n" if debug
    unable_to_verify = !tmp_s.include?("unknown") and !tmp_s.include?("250") ? true : false
    print unable_to_verify.to_s + "\n" if debug

    server.cmd("quit")
    print "disconnected\n" if debug

    continue or (unable_to_verify and pass_on_unable_to_verify)
  end
end