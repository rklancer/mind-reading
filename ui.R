library(shiny)

shinyUI(fluidPage(
    titlePanel("Buttons"),   
    actionButton("head", "Heads"),
    actionButton("tail", "Tails"),
    textOutput("message"),
    p("score: ", textOutput("computerScore"), " - ", textOutput("humanScore"))
))