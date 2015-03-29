Accounts.config
  sendVerificationEmail : true

if Meteor.isClient
  Meteor.startup ->

    Accounts.ui.config
      requestPermissions:
        facebook: ['email', 'read_friendlists', 'user_friends']

    if Config.username
      AccountsEntry.config
        homeRoute: '/'
        dashboardRoute: '/dashboard'
        profileRoute: 'profile'
        passwordSignupFields: 'USERNAME_AND_EMAIL'
    else
      AccountsEntry.config
        homeRoute: '/'
        dashboardRoute: '/dashboard'
        profileRoute: 'profile'
        passwordSignupFields: 'EMAIL_ONLY'