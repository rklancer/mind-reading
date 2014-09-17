library(shiny)

shinyUI(fluidPage(
    titlePanel("Buttons"),   
    actionButton("head", "Heads"),
    actionButton("tail", "Tails"),
    br(),
    p("who won: ", textOutput("message", span)),
    p("score: ", textOutput("computerScore", span), " - ", textOutput("humanScore", span)),
    actionButton("done", "had enough?"),
    plotOutput("plot")
))
