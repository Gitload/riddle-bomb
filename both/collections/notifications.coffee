Schemas.NotificationsData = new SimpleSchema
  data:
    type: Object
    blackbox: true

Notifications.attachSchema(Schemas.NotificationsData)