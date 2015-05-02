jsZip = Meteor.npmRequire 'jszip'
global = @

Meteor.methods(
  exportData: (userId, collectionName) ->
    check(userId,String)
    zip           = new jsZip()
    zip.file("#{collectionName}.json", JSON.stringify(global[collectionName].find().fetch(), null, 2))
    zip.generate({type: "base64"})
)