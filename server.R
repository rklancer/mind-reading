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

        data <- reader$getData()
        # deeply confused about whose perspective to take
        # ("victory" measn player victory, but nCorrect means # computer victories)
        list(message = ifelse(data$playerVictory, "you win", "I WIN!"), computerScore = data$nCorrect, humanScore = data$nTrials - data$nCorrect)
    })
    
    output$message <- renderText({ lastStats()$message })
    output$computerScore <- renderText({ lastStats()$computerScore })
    output$humanScore <- renderText({ lastStats()$humanScore })
})
