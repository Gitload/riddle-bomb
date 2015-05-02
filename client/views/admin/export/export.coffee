global = @

Template.adminExport.helpers
  collections: ->
    _.keys AdminConfig.collections

Template.adminExport.events(

  'submit #export': (event, template) ->
    event.preventDefault()

    form = $(event.target)
    userId = Meteor.userId()
    collectionName = form.find('#export-collections').val()

    Meteor.call('exportData', userId, collectionName, (error,response)->
      if error
        console.log error.reason
      else
        blob = do (response) ->
          byteCharacters = atob(response)
          byteNumbers = for byteCharacter, i in byteCharacters
            byteCharacters.charCodeAt(i)

          byteArray = new Uint8Array(byteNumbers)
          return new Blob [byteArray], type: "zip"

        saveAs(blob, 'export.zip')
    )

  'submit #import': (event, template) ->
    event.preventDefault()

    form = $(event.target)
    fileField = form.find("#import_file").get(0)
    file = _.first fileField.files
    collectionName = form.find('#import-collections').val()
    reader = new FileReader();

    reader.readAsText(file);
    reader.onload = ->
      documents = JSON.parse(reader.result);
      try
        for doc in documents
          global[collectionName].insert _.omit(doc, "_id"), (err) ->
            if err
              throw err.message
        AdminDashboard.alertSuccess "#{documents.length} documents have been successfully uploaded"
      catch err
        AdminDashboard.alertFailure err

      fileField.value = null
)

AdminDashboard.addSidebarItem 'Export', AdminDashboard.path('/export'), icon: 'plus'