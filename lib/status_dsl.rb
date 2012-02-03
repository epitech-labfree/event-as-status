##
## status_dsl.rb
## Login : <elthariel@hydre>
## Started on  Thu Feb  2 18:56:01 2012 Julien 'Lta' BALLET
## $Id$
##
## Author(s):
##  - Julien 'Lta' BALLET <elthariel@gmail.com>
##
## Copyright (C) 2012 Julien 'Lta' BALLET
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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

# This brick handle, for each status, 3 events. I will document here the format of the
# metadata of each event type :
#   - event-as-status.name.list
#     - { :scope => 'scope-name' }
#   - event-as-status.name.get
#     - { :scope => 'scope-name', :index => 'scope-index' }
#   - event-as-status.name.set
#     - { :scope => 'scope-name', :index => 'scope-index', :value => { 'x' => 'y' }}
#

module StatusDSL
  @@_status = Hash.new
  @@_scopes = {
    :meeting => ['internal.meeting.add', 'internal.meeting.delete']
  }

  def self.status(name)
    name = name.to_sym
    @@_status[name] = Status.new(name) unless @@_status.has_key? name

    yield @@_status[name]
    @@_status[name]._register
  end

  def self.scope(s)
    @@_scopes[s]
  end

  class Status
    attr_reader :name, :desc

    def initialize(name)
      @name = name
      @basetype = "event-as-status.#{name}"
      @desc = ""
      @scope = :meeting
      @index = Array.new
      @handlers = Hash.new

      @status = Hash.new
    end

    def description(string)
      @desc = string
    end

    def scope(s)
      @scope = s.to_sym
    end

    def event(event_type, &block)
      @handlers[event_type.to_s] = Proc.new block
    end

    def index(*args)
      @index = args
    end

    def _handler(event)
      Settings.i.logger.notice "Got a event in of type #{event['type']} in #{name}"

      type = event['type']

      if StatusDSL.scope(@scope).include? type
        _handle_scope event
      end
      if @handlers.include? type
        _status_update event
      end

      if type == "#{@basetype}.list"
        _status_list event
      elsif type == "#{@basetype}.get"
        _status_get event
      elsif type == "#{@basetype}.set"
        _status_set event
      end
    end

    def _handle_scope(event)
      type = event['type']
      name = event['location']

      if type == 'internal.meeting.add'
        @status[name] = Hash.new
      elsif type == 'internal.meeting.delete'
        @status.delete name
      end
    end

    def _status_update(event)
      type = event['type']

      begin
        @status[_scope(event)][_index(event)] = @handlers[type].call event, @status[_scope(event)][_index(event)]
      rescue
        Settings.i.logger.warn "Status update exception, maybe the scope doesn't exist ? (#{$!})"
      end
    end

    def _status_list(event)
      scope = event['metadata']['scope']
      meta = {:scope => scope, :list => @scope[scope]}

      UceEvent.i.event("#{basetype}.list", {:to => event['from'], :metadata => meta}, event['location'])
    end

    def _status_get(event)
      scope = event['metadata']['scope']
      index = event['metadata']['index']
      value = @status[scope][index]
      meta = {:scope => scope, :index => index, :value => value}

      UceEvent.i.event("#{basetype}.get", {:to => event['from'], :metadata => meta}, event['location'])
    end

    def _status_set(event)
      scope = event['metadata']['scope']
      index = event['metadata']['index']
      value = event['metadata']['value']

      @status[scope][index] = value
    end

    def _index(event)
      tmp = event
      @index.each { |i| tmp = tmp[i] }
    end

    def _scope(event)
      event['location'] if @scope == :meeting
    end

    def _register
      types = StatusDSL.scope(@scope).dup
      types.concat @handlers.keys
      types << "#{@basetype}.list"
      types << "#{@basetype}.set"
      types << "#{@basetype}.get"

      types.each do |t|
        Conf.i.logger.info "Status #{@name} : Registering event #{t}"
        UceLongPoller.i.handlers[t] ||= Array.new
        UceLongPoller.i.handlers[t] << Proc.new { |e| _handler e }
      end
    end

  end
end
