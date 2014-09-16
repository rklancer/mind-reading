mindReader <- function() {
    nTrials <- 0
    nCorrect <- 0
    pHistory <- c()
    nCorrectHistory <- c()
    
    lastChoice <- NULL
    plays <- c()
    situation <- c()
    playerVictory <- NULL
    
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
        nTrials <<- nTrials + 1
        # handle the win or loss
        playerVictory <<- choice != prediction
        
        if ( ! playerVictory ) {
            nCorrect <<- nCorrect + 1
        }
        
        p <- pbinom(nCorrect, nTrials, 0.5, lower.tail=F)
        pHistory <<- c(pHistory, p)
        nCorrectHistory <<- c(nCorrectHistory, nCorrect)        
        
        # store the play for use by prediction algorithm
        if ( ! is.null(lastChoice) ) {
            play = if (choice == lastChoice) 's' else 'd'
    
            if (nchar(situation) == 3) {
                # repeated use of [[ here because R doesn't let you grab a *reference* to the list element, it copies on assignment.
                pastPlaysBySituation[[situation]] <<- c(pastPlaysBySituation[[situation]], play)
            }
            plays <<- c(plays, play)
        }
        lastChoice <<- choice
        plays <<- c(plays, ifelse(playerVictory, 'w', 'l'))
         
        situation <<- paste(tail(plays, 3), collapse='')
        prediction <<- predict()
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
            play(choice)
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
    
    getData <- function() {
        list(
            playerVictory = playerVictory,
            nTrials = nTrials,
            nCorrect = nCorrect,
            nCorrectHistory = nCorrectHistory,
            pHistory = pHistory
        )
    }
    
    prediction <<- predict()
    
    list(go = go, play = play, getData = getData)
}
