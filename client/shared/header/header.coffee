notificationsVisible = new ReactiveVar()

toggleNotifications = ->
  if notificationsVisible.get()
    hideNotifications()
  else
    showNotifications()

hideNotifications = ->
  notificationsVisible.set(false)

showNotifications = ->
  notificationsVisible.set(true)

Template.header.helpers
  notificationsVisible : ->
    notificationsVisible.get()

Template.header.events
  "click .notificationsDropdown" : ->
    toggleNotifications()

Template.masterLayout.events
  "click" : (event) ->
    if !$(event.target).closest('.notificationsDropdown').length
      hideNotifications()