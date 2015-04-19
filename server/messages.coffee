Meteor.startup ->
  RiddleBomb.getPendingGames().observe
    added: (game) ->
      adminUser = RiddleBomb.getAdminUserByGame game
      invitedUser = RiddleBomb.getInvitedUserByGame game

      Notifications.new
        title: "You have been invited by #{adminUser.profile.firstName} #{adminUser.profile.lastName}"
        link: '/game/' + game._id
        icon: 'gamepad'
        owner: invitedUser._id,
        data: {
          gameId: game._id
        }


