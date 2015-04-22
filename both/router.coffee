Router.configure
  layoutTemplate: "masterLayout"
  loadingTemplate: "loading"
  notFoundTemplate: "notFound"
  routeControllerNameConverter: "camelCase"

Router.map ->
  @route "home",
    path: "/"

  @route "dashboard",
    waitOn: ->
      [
      ]
    onBeforeAction: ->
      url = Session.get 'redirectToAfterSignIn'
      if url
        Session.set 'redirectToAfterSignIn', null
        Router.go url
      @next()
    data: ->
      Posts: Posts.find({},{sort: {createdAt: -1}}).fetch()

  @route "profile",
    waitOn: ->
      Meteor.subscribe 'profilePictures'

  @route "account",
    onStop: ->
      Alert.clear()

  @route "setUserName",
    onBeforeAction: ->
      if not Config.username or (Meteor.userId() and Meteor.user().username)
        @redirect '/dashboard'
      @next()

  @route "findPlayers"

  @route "game/:_id",
    name: "game"
    data:  ->
      {
        gameId : this.params._id
      }

  @route "export",
    path: AdminDashboard.path('export')
    controller: 'AdminController'
    onAfterAction: ->
      Session.set 'admin_title', 'Import/Export Questions'

Router.waitOn ->
  Meteor.subscribe 'user'
  Meteor.subscribe 'userPicture'
  Meteor.subscribe 'questions'
  Meteor.subscribe 'games'


prepareView = ->
  window.scrollTo(0,0)
  $('body').removeClass('sidebar-active')

  #Fuck off broken modals
  $('.modal-backdrop').removeClass('in')
  $bd =  $('.modal-backdrop')
  setTimeout ->
    $bd.remove()
  , 300

  #For skrollr :(
  $('body').attr('style','')

Router.onAfterAction prepareView

#To allow non-logged in users to access more routes, add it in the config file
signInRequired = ->
  AccountsEntry.signInRequired @
  if @next
    @next()

saveRedirectUrl = ->
  unless Meteor.loggingIn()
    if not Meteor.user()
      Session.set 'redirectToAfterSignIn', @url
  @next()

redirectToRunningGame = ->
  runningGames = RiddleBomb.getRunningGamesForUser().fetch()
  if runningGames[0] && @.route.getName().indexOf('admin') == -1
      Router.go 'game', runningGames[0]
  @next()

publicRoutes = _.union Config.publicRoutes, ['entrySignIn','entrySignUp','entryForgotPassword']

Router.onBeforeAction saveRedirectUrl, {except: _.union publicRoutes, ['entrySignOut']}
Router.onBeforeAction signInRequired, {except: publicRoutes}
Router.onBeforeAction redirectToRunningGame

signInProhibited = ->
  if Meteor.user()
    Router.go('dashboard')
  else
    if @next
      @next()
      
Router.onBeforeAction signInProhibited, {only: ['entrySignUp','entrySignUp','entryForgotPassword']}
