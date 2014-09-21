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
