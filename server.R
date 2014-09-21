library(shiny)
source("mind-reader.R")
source("plots.R")

shinyServer(function(input, output) {

    reader <- mindReader()
    
    lastHeads <- 0
    lastTails <- 0
    lastComputerScore <- 0
    
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
        computerWin <- score$computerScore > lastComputerScore
        lastComputerScore <<- score$computerScore

        list(
            computerWin   = computerWin,
            computerScore = score$computerScore, 
            playerScore =   score$playerScore
        )
    })
    
    output$computerWin   <- renderText({ if (lastStats()$computerWin) 'T' else 'F' })
    outputOptions(output, 'computerWin', suspendWhenHidden=F)
    output$computerScore <- renderText({ lastStats()$computerScore })
    output$playerScore   <- renderText({ lastStats()$playerScore })
    
    history <- reactive({
        lastStats()
        history <- reader$getHistory()
        saveRDS(history, paste(c('history-', sample(letters, 5, replace=T), '.rds'), collapse=''))
        saveRDS(history, 'history.RDS')
        history
    })

    output$overallScoreAndPvalue <- renderPlot({
        print(plotOverallScoreAndPvalue(history()))
    })

    output$overallPlotAvailable <- renderText({
        if (length(history()$predictions) > 0) 'T' else 'F'
    })
    outputOptions(output, 'overallPlotAvailable', suspendWhenHidden=F)

    output$informedScoreAndPvalue <- renderPlot({
        print(plotInformedScoreAndPvalue(history()))
    })

    output$informedPlotAvailable <- renderText({
        if (any(history()$predictionInformed)) 'T' else 'F'
    })

    output$playsBySituation <- renderPlot({
        print(plotPlaysBySituation(history()))
    })
})
