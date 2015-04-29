@Options = new Meteor.Collection('options');

Schemas.Options = new SimpleSchema
  key:
    type:String
    allowedValues: _.keys Config.defaultOptions


  value:
    type: String

  format:
    type: String
    allowedValues: ['String', 'Number']
    defaultValue: 'String'

Options.helpers
  getValue: ->
    if @format == 'Number'
      parseInt @value
    else
      @value

Options.attachSchema(Schemas.Options)