library(shiny)

shinyUI(fluidPage(
    titlePanel("Buttons"),   
    actionButton("head", "Heads"),
    actionButton("tail", "Tails"),
    br(),
    textOutput("message", h2),
    p("score: ", textOutput("computerScore", span), " - ", textOutput("playerScore", span)),
    actionButton("done", "had enough?"),
    plotOutput("plot")
))
