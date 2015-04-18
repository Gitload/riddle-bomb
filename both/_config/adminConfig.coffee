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
  dashboard:
    homeUrl: '/dashboard'
  autoForm:
    omitFields: ['createdAt', 'updatedAt']

AdminDashboard.addSidebarItem 'Export', AdminDashboard.path('/export'), icon: 'plus'


