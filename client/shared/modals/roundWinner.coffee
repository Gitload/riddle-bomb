@Modals =
  showWinnerByRoundNumber: (roundNumber = 0)->
    roundWinnerInfo =
      template: Template.roundWinner
      title: "Round finished"
      doc:
        roundWinner: RiddleBomb.getRoundWinner(roundNumber)
    rd = ReactiveModal.initDialog(roundWinnerInfo);
    rd.show()
