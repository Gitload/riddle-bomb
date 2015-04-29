@AdminConfig =
  name: Config.name
  collections :

    Games: {
      color: 'blue'
      icon: 'gamepad'
      tableColumns: [
        {label: 'Id',name:'_id'},
        {label: 'Started', name: 'startedAt'}
      ]
    }

    Questions: {
      color: 'red'
      icon: 'question'
      tableColumns: [
        {label: 'Title',name:'title'}
      ]
    }

    Options: {
      color: 'green'
      icon: 'file-o'
      tableColumns: [
        {label: 'Key',name:'key'}
      ]
    }

  dashboard:
    homeUrl: '/dashboard'
  autoForm:
    omitFields: ['createdAt', 'updatedAt']

AdminDashboard.addSidebarItem 'Export', AdminDashboard.path('/export'), icon: 'plus'