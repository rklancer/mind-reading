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
        history
    })

    output$overallScoreAndPvalue <- renderPlot({
        print(plotOverallScoreAndPvalue(history()))
    })

    output$overallPlotAvailable <- renderText({
        if (length(history()$predictions) > 1) 'T' else 'F'
    })
    outputOptions(output, 'overallPlotAvailable', suspendWhenHidden=F)

    output$informedScoreAndPvalue <- renderPlot({
        print(plotInformedScoreAndPvalue(history()))
    })

    output$informedPlotAvailable <- renderText({
        if (sum(history()$predictionInformed) > 1) 'T' else 'F'
    })
    outputOptions(output, 'informedPlotAvailable', suspendWhenHidden=F)

    output$playsBySituation <- renderPlot({
        print(plotPlaysBySituation(history()))
    })
})
