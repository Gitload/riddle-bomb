$(document).bind "keydown keypresse", (e) ->
  routeName = Router.current().route.getName()
  if routeName.toLowerCase().indexOf("edit") == -1
    return

  if(e.keyCode == 8 || e.keyCode == 48)
    doPrevent = false
    if e.keyCode == 8
      d = e.srcElement || e.target
      if d.tagName.toUpperCase() == 'INPUT' || d.tagName.toUpperCase() == 'TEXTAREA'
        doPrevent = d.readOnly || d.disabled
      else
        doPrevent = true
    else
      doPrevent = false

    if doPrevent
      if (!confirm 'Are you sure you want to leave this page?')
        e.preventDefault()