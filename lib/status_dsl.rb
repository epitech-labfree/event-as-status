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

module StatusDSL
  @@_status = Hash.new

  def self.status(name, &block)
    name = name.to_sym
    @@_status[name] = Status.new(name) unless @@_status.has_key? name

    @@_status[name].instance_eval(block)
  end

  class Status
    def initialize(name)
      @name = name
      @desc = ""
      @scope = :meeting
      @index = Array.new
      @handlers = Hash.new
    end

    def description(string)
      @desc = string
    end

    def scope(s)
      @scope = s.to_sym
    end

    def default(value)
      @default = value
    end

    def event(event_type, &block)
      @handlers[event_type.to_s] = Proc.new block
    end

  end
end
