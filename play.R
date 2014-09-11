prediction <- NULL
trials <- 0
nCorrect <- 0

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

lastChoice <- NULL
plays <- c()
situation <- c()

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
    last2Plays = tail(pastPlaysBySituation[situation], 2)
    
    prediction <<- if (length(last2Plays) >= 2 && last2Plays[1] == last2Plays[2]) {
        ifelse(last2Plays[2] == 's', lastChoice, other(lastChoice))
    }
    else {
        sample(c('h', 't'), 1)
    }
}

go <- function() {
    repeat {
        prediction <<- predict()
        choice <- readline()[1]
        if (choice == 'q') {
            print("quitting")
            return()
        }
        victory <- play(choice)
        trials <<- trials + 1
        if ( victory ) {
            print('YOU WIN');
        } else {
            nCorrect <<- nCorrect + 1
            print('I WIN')
            print(paste0('I have won ', 100 * nCorrect/trials, '% of trials (', nCorrect, ' of ', trials, '). p = ', pbinom(nCorrect, trials, 0.5, lower.tail=F)))
        }
    }
}
