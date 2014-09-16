library(shiny)
source("mind-reader.R")

shinyServer(function(input, output) {
    reader <- mindReader()
    
    lastHeads <- -1
    lastTails <- -1
    
    lastStats <- reactive({
        if (input$tail > lastTails) {
            lastTails <<- input$tail
            play <- "t"
        }
        if (input$head > lastHeads) {
            lastHeads <<- input$head
            play <- "h"
        }
        # play
        
        victory <- reader$play(play)
        data <- reader$getData()
        # deeply confused about whose perspective to take
        # ("victory" measn player victory, but nCorrect means # computer victories)
       # ifelse(victory, "you win", "I WIN!")
        list(message = ifelse(victory, "you win", "I WIN!"), computerScore = data$nCorrect, humanScore = data$nTrials - data$nCorrect)
    })
    
    output$message <- renderText({ lastStats()$message })
    output$computerScore <- renderText({ lastStats()$computerScore })
    output$humanScore <- renderText({ lastStats()$humanScore })
})
