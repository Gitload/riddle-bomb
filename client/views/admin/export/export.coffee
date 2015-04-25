##Receipe from https://github.com/themeteorchef/exporting-data-from-your-meteor-application/blob/master/code/client/controllers/authenticated/export.coffee
Template.adminExport.events(

  'click .export-data': ->
    # Get the current user's ID.
    userId = Meteor.userId()
    # Call our exportData method on the server, passing the userId so we can
    # use it to lookup data on the server.
    Meteor.call('exportData', userId, (error,response)->
      if error
        console.log error.reason
      else
        # This is where things get tricky. In order to get our download to work
        # using FileSaver.js, we need to convert our base64 string into a blob.
        # Honestly, this is where things go a bit over my head. I experimented
        # with a few different encoding types with this one yielding
        # the expected result. It's recommended that you try out your own
        # methods, too, to see if there's a more efficient way to do this.
        # See: http://stackoverflow.com/questions/16245767/creating-a-blob-from-a-base64-string-in-javascript
        base64ToBlob = (base64String) ->
          byteCharacters = atob(base64String)
          byteNumbers    = new Array(byteCharacters.length)
          i              = 0
          while i < byteCharacters.length
            byteNumbers[i] = byteCharacters.charCodeAt(i)
            i++
          byteArray = new Uint8Array(byteNumbers)
          return blob = new Blob([byteArray],
            type: "zip"
          )
        blob = base64ToBlob(response)
        saveAs(blob, 'export.zip')
    )

  'change .myFileInput': (event, template) ->
    FS.Utility.eachFile event, (file) ->
      if !err?
        reader = new FileReader();
        reader.readAsText(file);
        reader.onload = ->
          questions = JSON.parse(reader.result);
          for question in questions
            Questions.insert _.omit(question, "_id")
          AdminDashboard.alertSuccess "#{questions.length} questions have been successfully uploaded"
          event.target.value = null
)