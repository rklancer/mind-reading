nTrials <- 0
nCorrect <- 0
pHistory <- c()
nCorrectHistory <- c()

prediction <- NULL
lastChoice <- NULL
plays <- c()
situation <- c()

pastPlaysBySituation <- list(
    wsw = c(),
    wsl = c(),
    wdw = c(),
    wdl = c(),
    lsw = c(),
    lsl = c(),
    ldw = c(),
    ldl = c()
)

play <- function(choice) {
    victory <- choice != prediction
    
    if ( ! is.null(lastChoice) ) {
        play = if (choice == lastChoice) 's' else 'd'

        if (nchar(situation) == 3) {
            # repeated use of [[ here because R doesn't let you grab a *reference* to the list element, it copies on assignment.
            pastPlaysBySituation[[situation]] <<- c(pastPlaysBySituation[[situation]], play)
        }
        plays <<- c(plays, play)
    }
    lastChoice <<- choice
    plays <<- c(plays, ifelse(victory, 'w', 'l'))
      
    situation <<- paste(tail(plays, 3), collapse='')
    prediction <<- predict()
    
    victory
}

other <- function(choice) {
    if (choice == 'h') 't' else 'h'
}
    
predict <- function() {
    hasLast2Plays <- F
    if ( !is.null(situation) && nchar(situation) == 3) {
        last2Plays <- tail(pastPlaysBySituation[[situation]], 2)
        hasLast2Plays <- length(last2Plays) == 2
    }
    
    prediction <<- if (hasLast2Plays && last2Plays[1] == last2Plays[2]) {
        ifelse(last2Plays[2] == 's', lastChoice, other(lastChoice))
    }
    else {
        sample(c('h', 't'), 1)
    }
}

go <- function() {
    prediction <<- predict()
    repeat {
        choice <- readline()[1]
        
        if (choice == 'q') {
            plot(pHistory)
            return()
        }
        if ( ! any(choice == c('h', 't')) ) {
            cat("bad choice:", choice)
            next
        }
        playerVictory <- play(choice)
        nTrials <<- nTrials + 1
        if ( ! playerVictory ) {
            nCorrect <<- nCorrect + 1
            cat('HAH! I WIN.\n')           
        }
        p <- pbinom(nCorrect, nTrials, 0.5, lower.tail=F)
        pHistory <<- c(pHistory, p)
        nCorrectHistory <<- c(nCorrectHistory, nCorrect)
        cat(nCorrect, "-", nTrials - nCorrect, "\n")
    }
}
