mindReader <- function() {

    predictions <- c()
    choices <- c()
    predictionInformed <- c()

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
    
    ## Pure functions   

    flip <- function() {
        sample(c('h', 't'), 1)
    }

    concat <- function(v) {
        paste(v, collapse='')
    }

    choose <- function(headsOrTails, play) {
        list(
            hs = 'h',
            hd = 't',
            ts = 't',
            td = 'h'
        )[[concat(c(headsOrTails, play))]]
    }

    winsAndLosses <- function(predictions, choices) {
        ifelse(predictions == choices, 'l', 'w')
    }

    plays <- function(choices) {
        n <- length(choices)
        ifelse(tail(choices, n-1) == head(choices, n-1), 's', 'd')
    }

    situations <- function(predictions, choices) {
        # sequence of 'w', 'l'
        wl <- winsAndLosses(predictions, choices)
        # sequence of 's', 'd'
        sd <- plays(choices)

        n <- length(sd)
        M <- rbind(head(wl, n), sd, tail(wl, n))
        apply(M, 2, concat)
    }

    ## getters (affected by, but don't change, state)

    # 'wsw', etc; NA if not enough plays yet (i.e,. < 2 plays)
    getSituation <- function() {
        situations(tail(predictions, 2), tail(choices, 2))[1]
    }

    predict <- function() {
        situation <- getSituation()

        if ( ! is.na(situation) ) {
            last2Plays <- tail(pastPlaysBySituation[[situation]], 2)
            if (length(last2Plays) == 2 && identical(last2Plays[1], last2Plays[2])) {
                return(list(
                    prediction = choose(tail(choices, 1), last2Plays[1]),
                    informed = TRUE
                ))
            }
        }

        list(
            prediction = flip(),
            informed = FALSE
        )
    }

    getScore <- function() {
        list(
            computerScore = sum(predictions == choices),
            playerScore =   sum(predictions != choices)
        )
    }
    
    getHistory <- function() {
        list(
            choices = choices,
            predictions = predictions,
            predictionInformed = predictionInformed,
            situations = situations(predictions, choices),
            pastPlaysBySituation = pastPlaysBySituation
        )
    }    

    ## stateful updates

    # Statefully updates pastPlaysBySituation with the most recent choice.
    # (Better than recaculating it every play)
    # Be sure to call this only once per play.
    updatePastPlaysBySituation <- function(situation, play) {
        if ( is.na(situation) ) {
            return()
        }
        pastPlaysBySituation[[situation]] <<- c(pastPlaysBySituation[[situation]], play)
    }

    play <- function(choice) {

        if ( ! (identical(choice, 'h') || identical(choice, 't')) ) {
            # raise an error?
            return()
        }

        # predict the choice before looking at it. No cheating!
        results <- predict()

        # before updating 'plays' and 'choices' associate the current play with the situation that
        # preceded it
        previousSituation <- getSituation()
        play <- plays(c(tail(choices, 1), choice))
        updatePastPlaysBySituation(previousSituation, play)

        # and record the prediction and choice
        predictions <<- c(predictions, results$prediction)
        predictionInformed <<- c(predictionInformed, results$informed)
        choices <<- c(choices, choice)
    }
    
    list(
        play = play,
        getScore = getScore,
        getHistory = getHistory
    )
}
