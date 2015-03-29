@RiddleBomb =
  getUserByFacebookId: (facebookId) ->
    return Meteor.users.find({"services.facebook.id" : facebookId})

  getUsersByFacebookCollection: (facebookCollection) ->
    users = []
    console.log(facebookCollection)
    for friend in facebookCollection
      console.log(friend)
      users.push friend.name
    return users

  getFriendPlayers: ->
    console.log('get friends');
    return FacebookCollections.getFriends('me')
    return @getUsersByFacebookCollection(facebookCollection)


