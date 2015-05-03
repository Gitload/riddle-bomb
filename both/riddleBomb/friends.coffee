if Meteor.isClient
  facebookFriends = new ReactiveVar(new Meteor.Collection(null).find {})

  Meteor.startup ->
    Tracker.autorun ->
      if Meteor.userId()
        facebookFriends.set FacebookCollections.getFriends('me').find {}

  @RiddleBombFriends =
    getFacebookFriends: ->
      facebookFriends.get()