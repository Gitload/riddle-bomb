jsZip      = Meteor.npmRequire 'jszip'

Meteor.methods(
  exportData: (userId) ->
    # Check the format of the userId. Check allows us to assert that arguments
    # to a function have the right types and structure to preven unwanted data
    # being inserted into the DB.
    # See: https://docs.meteor.com/#/full/check_package
    # See: https://docs.meteor.com/#/full/auditargumentchecks
    check(userId,String)

    # Setup our zip instance and define folders for each type of data.
    # Note: folders are optional but nice for organization. Here, we're only
    # making one folder to demonstrate the technique.
    zip           = new jsZip()

    zip.file('questions.json', JSON.stringify(Questions.find().fetch(), null, 2))
    zip.generate({type: "base64"})
)