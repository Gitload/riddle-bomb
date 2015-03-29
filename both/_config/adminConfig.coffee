@AdminConfig =
  name: Config.name
  collections :

    Games: {
      color: 'blue'
      icon: 'gamepad'
    }
    Questions: {
      color: 'red'
      icon: 'question'
      tableColumns: [
        {label: 'Title',name:'title'}
      ]
    }
    Comments: {
      color: 'green'
      icon: 'comments'
      auxCollections: ['Posts']
      tableColumns: [
        {label: 'Content',name:'content'}
        {label:'Post',name:'doc',collection: 'Posts',collection_property:'title'}
        {label:'User',name:'owner',collection:'Users'}
      ]
    }
  dashboard:
    homeUrl: '/dashboard'
    # widgets: [
    # 	{
    # 		template: 'adminCollectionWidget'
    # 		data:
    # 			collection: 'Posts'
    # 			class: 'col-lg-3 col-xs-6'
    # 	}
    # 	{
    # 		template: 'adminUserWidget'
    # 		data:
    # 			class: 'col-lg-3 col-xs-6'
    # 	}
    # ]
  autoForm:
          omitFields: ['createdAt', 'updatedAt']

