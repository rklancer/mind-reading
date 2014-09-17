mindReader <- function() {
    nTrials <- 0
    nCorrectPredictions <- 0
    nCorrectInformedPredictions <- 0
    nInformedPredictions <- 0
    pHistory <- c()
    nCorrectHistory <- c()
    
    lastChoice <- NULL
    plays <- c()
    situation <- c()
    correctPrediction <- NULL
    # was prediction informed by data, or random?
    informedPrediction <- FALSE
    
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
        
        # increment this here, rather than at prediction time, so at the end we don't count the unused prediction
        if (informedPrediction) {
            nInformedPredictions <<- nInformedPredictions + 1
        }
            
        # handle the win or loss
        correctPrediction <<- (choice == prediction)
        
        if ( correctPrediction ) {
            nCorrectPredictions <<- nCorrectPredictions + 1
            if (informedPrediction) {
                nCorrectInformedPredictions <<- nCorrectInformedPredictions + 1
            }
        }
        
        p <- pbinom(nCorrectPredictions, nTrials, 0.5, lower.tail=F)
        # pHistory should perhaps be calculated by client code using nCorrectHistory
        pHistory <<- c(pHistory, p)
        nCorrectHistory <<- c(nCorrectHistory, nCorrectPredictions)        
        
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
        plays <<- c(plays, ifelse(correctPrediction, 'l', 'w'))
         
        situation <<- paste(tail(plays, 3), collapse='')
        prediction <<- predict()
    }
    
    other <- function(choice) {
        if (choice == 'h') 't' else 'h'
    }
        
    predict <- function() {
        hasLast2Plays <- FALSE
        if ( !is.null(situation) && nchar(situation) == 3) {
            last2Plays <- tail(pastPlaysBySituation[[situation]], 2)
            hasLast2Plays <- length(last2Plays) == 2
        }
        
        if (hasLast2Plays && last2Plays[1] == last2Plays[2]) {
            informedPrediction <<- TRUE
            return(ifelse(last2Plays[2] == 's', lastChoice, other(lastChoice)))
        }
        else {
            informedPrediction <<- FALSE
            return(sample(c('h', 't'), 1))
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
            if ( correctPrediction ) {
                nCorrectPredictions <<- nCorrectPredictions + 1
                cat('HAH! I WIN.\n')           
            }
            p <- pbinom(nCorrectPredictions, nTrials, 0.5, lower.tail=F)
            pHistory <<- c(pHistory, p)
            nCorrectHistory <<- c(nCorrectHistory, nCorrectPredictions)
            cat(nCorrectPredictions, "-", nTrials - nCorrectPredictions, "\n")
        }
    }
    
    getStats <- function() {
        list(
            correctPrediction = correctPrediction,
            nTrials = nTrials,
            nCorrectPredictions = nCorrectPredictions,            
            nInformedPredictions = nInformedPredictions,
            nCorrectInformedPredictions = nCorrectInformedPredictions
        )
    }

    getStatsHistory <- function() {
        list(
            nCorrectHistory = nCorrectHistory,
            pHistory = pHistory
        )
    }
    
    prediction <<- predict()
    
    list(go = go, play = play, getStats = getStats, getStatsHistory = getStatsHistory)
}
