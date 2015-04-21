regexTestValues = new ReactiveVar()
regexTestValues.set {}

answerOptions = new ReactiveVar()
answerOptions.set {}

refreshItems = (event) ->
  answers = answerOptions.get()
  answers[@name] = event.target.value
  answerOptions.set answers

AutoForm.addInputType 'tags',
  template: 'autoformTagsRegex'
  valueOut: (event) ->
    console.log @
    console.log event
    @val()
  valueConverters:
    stringArray: (value) ->
      value.split ','

Template.autoformTagsRegex.helpers
  autoformTagsTemplate: ->
    return "autoformTags"

  hasInput: ->
    values = regexTestValues.get()
    return values[@name]?

  checkRegex: ->
    values = regexTestValues.get()
    if values[@name]?
      options = answerOptions.get()[@name] || ""
      answers = options.split(",")
      return RiddleBombUtils.inputFitsAnswer(values[@name], answers)
    else
      return false

  values: ->
    values = answerOptions.get()
    return values[@name]

Template.autoformTags.events
  "itemAdded input": refreshItems
  "itemRemoved input": refreshItems


Template.autoformTagsRegex.events
  "keyup .check-regex" : (event) ->
    input = event.target.value
    values = regexTestValues.get()
    if input != ''
      values[@name] = input
    else if values[@name]?
      delete values[@name]
    regexTestValues.set values