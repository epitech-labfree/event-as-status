##
## video.rb
## Login : <elthariel@hydre>
## Started on  Thu Feb  2 18:45:47 2012 Julien 'Lta' BALLET
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

status :streams do |status|
  status.description "keeps track of stream_started and stream_stopped"
  status.scope :meeting
  status.index :metadata, :user_uid

  status.event :ev_stream_started do |event, current_status|
    Conf.i.logger.debug "Status #{status.name}, ev_stream_started"
    puts event["metadata"]["user_uid"]
    event["metadata"]
  end

  status.event :ev_stream_stopped do |event, current_status|
    Conf.i.logger.debug "Status #{status.name}, ev_stream_stopped"
    nil
  end
end

