fbFriendsDependency = new Tracker.Dependency;

@RiddleBomb =
  getUserByFacebookId: (facebookId) ->
    return Meteor.users.findOne(
      "services.facebook.id" : facebookId,
      {
        transform : (doc) ->
          doc.name = doc.services.facebook.name
          console.log(doc)
          return doc
      }
    )

  getUserByFacebookUser: (facebookUser) ->
    return @getUserByFacebookId facebookUser.id

  getFacebookFriends: ->
    return FacebookCollections.getFriends('me').find {}
