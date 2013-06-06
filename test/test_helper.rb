require 'test/unit'
require 'rubygems'
require File.dirname(__FILE__) + '/../lib/trustcommerce'

begin
  require 'mocha/setup'
rescue LoadError
  puts "Mocha required to run tests. `gem install mocha` and try again."
  exit 1
end

TCLINK_LIB_INSTALLED = TrustCommerce.tclink?

def via_tclink_and_https
  # test via TCLink
  if !TCLINK_LIB_INSTALLED
    puts 'TCLink library not installed - skipping tests via TCLink'
  else
    TrustCommerce.stubs(:tclink?).returns(true)
    yield
  end
  
  # test via https
  TrustCommerce.stubs(:tclink?).returns(false)
  yield
end

def create_subscription!(name)
  response = TrustCommerce::Subscription.create(
    :cc       => CARDS[:visa][:cc], 
    :exp      => CARDS[:visa][:exp],
    :address1 => CARDS[:visa][:address],
    :zip      => CARDS[:visa][:zip],
    :avs      => 'y',      
    :name     => name,
  	:amount   => 1200,
  	:cycle    => '1m',
    :demo     => 'y'
  )
  assert_equal 'approved', response[:status]    
  assert response.keys.include?(:billingid)
  response[:billingid]
end

def create_test_transaction!(billing_id)
  puts 'Posting test transaction...'

  charge_response = TrustCommerce::Subscription.charge(
    :billingid  => billing_id,
    :amount     => 1995,
    :demo       => 'y'
  )

  # query for charges
  options = { :querytype => 'summary', :billingid => billing_id }

  while (query_response = TrustCommerce::Subscription.query(options))
    if query_response.body =~ /error/i
      fail(query_response.body)
      break
    elsif query_response.body.split("\n").size < 2
      puts 'Transaction has not yet showed up... will try again in 15 seconds.'
      sleep(15)
    else
      puts 'Transaction found.'
      break
    end
  end
end

# --- [ TrustCommerce test data ] ---
# reference: https://vault.trustcommerce.com/downloads/TCDevGuide.html#testdata
CARDS = {
  :visa       => { :cc      => '4111111111111111', 
                   :exp     => '0412', 
                   :cvv     => 123,
                   :address => '123 Test St.', 
                   :city    => 'Somewhere', 
                   :state   => 'CA', 
                   :zip     => 90001 },
  :mastercard => { :cc      => '5411111111111115', 
                   :exp     => '0412', 
                   :cvv     => 777,
                   :address => '4000 Main St.', 
                   :city    => 'Anytown', 
                   :state   => 'MA', 
                   :zip     => 85001 },
  :amex       => { :cc      => '341111111111111',  
                   :exp     => '0412', 
                   :cvv     => 4000,
                   :address => '12 Colorado Blvd.', 
                   :city    => 'Elsewhere', 
                   :state   => 'IL', 
                   :zip     => 54321 }
}