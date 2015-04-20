@Questions = new Meteor.Collection('questions');

Schemas.Entries = new SimpleSchema
  title:
    type:String

  "answers":
    type: Array
    optional: true

  "answers.$":
    type: [String]
    autoform:
      type: 'tags'
      afFieldInput:
        trimValue: true
        tagClass: (inputValue) ->
          cssClass = 'tag label '
          cssClass += if RiddleBomb.optionIsRegex(inputValue) then 'label-warning' else 'label-info'
          return cssClass

Questions.attachSchema(Schemas.Entries)