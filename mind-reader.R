mindReader <- function() {

    # total number of user's head or tail calls
    nTrials <- 0

    # total number of calls guessed correctly by the algorithm
    nCorrectPredictions <- 0

    # total number of calls guessed correctly by the algorithm where the prediction was made
    # based on past user plays (i.e., this excludes random guesses)
    nCorrectInformedPredictions <- 0

    # total number of calls where the algorithm guessed based on past user plays, i.e., non-randomly
    nInformedPredictions <- 0

    # history of p-values of one-sided binomial test of null hypothesis that computer's predictions
    # are different that user's plays with P = 0.5, assuming indepdence of plays.
    pHistory <- c()

    # history of number of correct guesses
    nCorrectHistory <- c()
    
    lastChoice <- NULL

    # character vector of all "plays", except the first, indicating whether player played
    # same or different. 
    # (play[i] == 's' means player played Same in trial i+1, 'd' means Different)
    plays <- c()

    # the current "situation", as defined by Shannon, as a character vector 
    # (e.g., 'wsw' == player Won, played Same, Won, etc.)
    # usually of length 3 (length is 0 before the first play, 1 before the second)
    situation <- c()

    # was the most recently tested prediction correct?
    correctPrediction <- NULL

    # was the current prediction informed by data, or random?
    informedPrediction <- FALSE
    
    # for each past "situation" (eg player Won, played Same, Won), whether the user played same ('s')
    # or different ('d')
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
        
        # increment this here, rather than at prediction time, so we don't count the unused prediction at the end
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
            pHistory = pHistory,
            pastPlaysBySituation = pastPlaysBySituation
        )
    }
    
    prediction <<- predict()
    
    list(
        go = go, 
        play = play, 
        getStats = getStats, 
        getStatsHistory = getStatsHistory
    )
}
