library(shiny)
source("mind-reader.R")

shinyServer(function(input, output) {
    reader <- mindReader()
    
    lastHeads <- 0
    lastTails <- 0
    
    lastStats <- reactive({
        if (input$tail > lastTails) {
            lastTails <<- input$tail
            reader$play("t")
        }
        if (input$head > lastHeads) {
            lastHeads <<- input$head
            reader$play("h")
        } 

        stats <- reader$getStats()

        list(
            message = ifelse(is.null(stats$correctPrediction),
                "", 
                ifelse(stats$correctPrediction,
                    "I WIN!", 
                    "ok, you win this one..."
                )
            ),
            computerScore = stats$nCorrectPredictions, 
            humanScore = stats$nTrials - stats$nCorrectPredictions
        )
    })
    
    output$message <- renderText({ lastStats()$message })
    output$computerScore <- renderText({ lastStats()$computerScore })
    output$humanScore <- renderText({ lastStats()$humanScore })
})
