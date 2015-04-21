@RiddleBombUtils =
  inputFitsAnswer : (input, answerOptions) ->
    fits = false
    for option in answerOptions
      if option.toLowerCase() == input.toLowerCase()
        fits = true
      if RiddleBomb.optionIsRegex(option)
        regex = new RegExp(option.replace(/\//g, ""), "i")
        if input.match(regex)
          fits = true

    return fits