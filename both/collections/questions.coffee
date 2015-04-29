@Questions = new Meteor.Collection('questions');

Schemas.Entries = new SimpleSchema
  title:
    type:String

  subtitle:
    type:String
    optional: true

  "answers":
    type: Array
    minCount: 2

  "answers.$":
    type: [String]
    minCount: 1
    autoform:
      type: 'tags'
      afFieldInput:
        trimValue: true
        tagClass: (inputValue) ->
          cssClass = 'tag label '
          cssClass += if RiddleBomb.optionIsRegex(inputValue) then 'label-warning' else 'label-info'
          return cssClass

Questions.attachSchema(Schemas.Entries)