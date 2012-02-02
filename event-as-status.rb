#! /usr/bin/env ruby
## uce_connector.rb
## Login : <elthariel@hydre>
## Started on  Wed May 25 13:52:44 2011 Julien 'Lta' BALLET
## $Id$
##
## Author(s):
##  - Julien 'Lta' BALLET <elthariel@gmail.com>
##
## Copyright (C) 2011 Julien 'Lta' BALLET
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
##

require 'rubygems'
require 'logger'
require 'yaml'

$:.unshift File.dirname(File.expand_path $0) + '/lib'

require 'settings'
require 'uce_event'
require 'uce_login'
require 'uce_longpoller'
require 'status_dsl'

$log = Conf.i.logger
$log.warn "Starting 'event-as-status' brick"
$status = Hash.new # FIXME

#
# Dirty implementation, replace this by a nice rubbyish DSL
#

UceLongPoller.i.handlers["ev_stream_started"] = Proc.new do |event|
  $status[event['location']] = Hash.new unless $status.has_key? event['location']

  $status[event['location']][event['metadata']['user_uid']] = event
end

UceLongPoller.i.handlers["ev_stream_stopped"] = Proc.new do |event|
  $status[event['location']].delete event['metadata']['user_uid']
end

UceLongPoller.i.handlers["event-as-status.list"] = Proc.new do |event|
  return unless event.has_key? 'location'

  room = event['location']
  UceEvent.i.event-as-status({:to => event['from'], :metadata => $status[room]}, room)
end

module StatusDSL
Dir["status/*.rb"].each do |file|
      puts "Loading a status: #{file} ..."
      File.open(file, 'r') do |fh|
      lines = fh.readlines
      module_eval lines.join, file
    end
  end
end

EM.run do
  UceLogin.new(Proc.new { |uid, sid| puts "Connected with #{uid}, #{sid}"},
               Proc.new { |u, s| UceLongPoller.i.on_login(u, s) },
               Proc.new { |u, s| UceEvent.i.on_login(u, s) })
end
