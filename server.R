library(shiny)
source("mind-reader.R")

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
    
    output$plot <- renderPlot({
        if (input$done > 0) {
            history <- reader$getHistory()
            trials <- history$choices == history$predictions

            pHistory <- sapply(1:length(trials), function(n) {
                binom.test(sum(trials[1:n]), n, 0.5, alternative='greater')$p.value
            })

            plot(pHistory)

            saveRDS(history, paste(c('history-', sample(letters, 5, replace=T), '.rds'), collapse=''))
            saveRDS(history, 'history.RDS')
        }
    })
})
