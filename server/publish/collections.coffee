Meteor.publish 'posts', ->
	Posts.find()

Meteor.publish 'questions', ->
  Questions.find()

Meteor.publish 'games', ->
  Games.find()

Meteor.publish 'attachments', ->
	Attachments.find()

Meteor.publish 'options', ->
  Options.find()
