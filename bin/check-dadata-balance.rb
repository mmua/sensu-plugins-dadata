#!/usr/bin/env ruby
#
#   check-dadata-balance
#
# DESCRIPTION:
#   This plugin checks balance
#
# OUTPUT:
#   Plain text
#
# PLATFORMS:
#   Linux, BSD, Windows, OS X
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rest-client
#
# USAGE:
#   This gem requires a JSON configuration file with the following contents:
#     {
#       "dadata": {
#         "token": "YOUR_DADATA_TOKEN",
#         "secret": "YOUR_DADATA_SECRET"
#       }
#     }
#   For more details, please see the README.
#
# NOTES:
#
# LICENSE:
#
#   Copyright 2017 Maxim Moroz <maxim.moroz@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'sensu-plugin/utils'
require 'restclient'
require 'cgi'
require 'erb'

class DadataBalanceCheck < Sensu::Plugin::Check::CLI
  include Sensu::Plugin::Utils
  option :json_config,
         description: 'Config name',
         short: '-j config_key',
         long: '--json_config config_key',
         required: false

  def dadata_token
    settings['dadata']['token']
  end

  def dadata_secret
    settings['dadata']['secret']
  end

  def run
    auth_data = {
        'Authorization': "Token #{dadata_token}",
        'X-Secret': dadata_secret
    }
    resp = RestClient::Request.execute(method: :get, url: 'https://dadata.ru/api/v2/profile/balance',
                            timeout: 10, headers: auth_data)
    balance = JSON.parse(resp)['balance']
    if balance > 200
       ok 'DaData balance OK: ' + balance.to_s
    elsif balance > 100
       warning 'DaData balance low: ' + balance.to_s
    else
       critical 'DaData balance: ' + balance.to_s
    end
    clear_error
  end

end
