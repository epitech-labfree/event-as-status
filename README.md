# event-as-status

This project is a functional 'brick' for [af83/ucengine](https://github.com/af83/ucengine), a fast and persistent pubsub server.

It's written in Ruby and uses Event Machine and em-http-request.

It reacts to user-defined event by creating and updating a status list, allowing users to query this status when then join a meeting and doesn't want to replay the events to get the actual state of a particular user/brick/...

It was developped to simply keep track of currently playing video streams inside a meeting, so a user joining the meeting could easily obtain, in a more reliable manner that a roster/list, the list of stream he should instantiate flash widget for.

The differents status and related event it keeps track of are defined using a really simple DSL, of which there's an example below.

# DSL Example

```ruby
status :streams do |status|
  status.description "keeps track of stream_started and stream_stopped"
  status.scope :meeting
  status.index :metadata, :user_uid

  status.event :ev_stream_started do |event, current_status|
    Conf.i.logger.debug "Status #{status.name}, ev_stream_started"
    event
  end

  status.event :ev_stream_stopped do |event, current_status|
    Conf.i.logger.debug "Status #{status.name}, ev_stream_stopped"
    nil
  end
end
```

# API Example

This brick handle, for each 'status', 3 events. I will document here the format of the
metadata of each event type :

* event-as-status.status.list
     *{ :scope => 'scope-name' }
* event-as-status.status.get
     * { :scope => 'scope-name', :index => 'scope-index' }
* event-as-status.status.set
     * { :scope => 'scope-name', :index => 'scope-index', :value => { 'x' => 'y' }}


