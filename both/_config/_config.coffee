@Config =
  name: 'RiddleBomb'
  title: 'Who knows more?'
  subtitle: 'A boilerplate from MeteorFactory.io'
  logo: ->
    '<b>' + @name + '</b>'
  footer: ->
    @name + ' - Copyright ' + new Date().getFullYear()
  emails:
    from: 'noreply@' + Meteor.absoluteUrl()
  blog: 'http://meteorfactory.io'
  about: 'http://meteorfactory.io'
  username: false
  homeRoute: '/'
  dashboardRoute: '/dashboard'
  socialMedia:
    facebook:
      url: 'http://facebook.com/'
      icon: 'facebook'
  publicRoutes: ['home']
  defaultOptions:
    pointsToWin: 5
    timeForDraw: 150000
    timeForBreak: 5
