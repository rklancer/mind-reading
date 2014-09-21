library(shiny)
source("mind-reader.R")
source("plots.R")

shinyServer(function(input, output) {
    reader <- mindReader()
    
    lastHeads <- 0
    lastTails <- 0
    lastPlayerScore <- 0
    
    lastStats <- reactive({
        if (input$tail > lastTails) {
            lastTails <<- input$tail
            reader$play("t")
        }
        if (input$head > lastHeads) {
            lastHeads <<- input$head
            reader$play("h")
        }

        score <- reader$getScore()
        playerWin <- score$playerScore > lastPlayerScore
        lastPlayerScore <<- score$playerScore
        totalScore <- score$computerScore + score$playerScore

        list(
            message =       if (totalScore == 0) "" else if (playerWin) "" else "I WIN!!!",
            computerScore = score$computerScore, 
            playerScore =   score$playerScore
        )
    })
    
    output$message       <- renderText({ lastStats()$message })
    output$computerScore <- renderText({ lastStats()$computerScore })
    output$playerScore   <- renderText({ lastStats()$playerScore })
    
    history <- reactive({
        lastStats()
        saveRDS(history, paste(c('history-', sample(letters, 5, replace=T), '.rds'), collapse=''))
        saveRDS(history, 'history.RDS')
        reader$getHistory()
    })

    output$overallScoreAndPvalue <- renderPlot({
        print(plotOverallScoreAndPvalue(history()))
    })

    output$informedScoreAndPvalue <- renderPlot({
        print(plotInformedScoreAndPvalue(history()))
    })

    output$playsBySituation <- renderPlot({
        print(plotPlaysBySituation(history()))
    })
})
