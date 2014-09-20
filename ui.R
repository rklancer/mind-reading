library(shiny)

shinyUI(fluidPage(
    titlePanel("A Mind-Reading (?) Machine, Analyzed"),

    sidebarLayout(
    	sidebarPanel(
	    	actionButton("head", "Left"),
	    	actionButton("tail", "Right"),
	    	br(),
	    	textOutput("message", h2),
	    	p("score: ", textOutput("computerScore", span), " - ", textOutput("playerScore", span)),
	    	actionButton("done", "Done!")
    	),
	    mainPanel(
	      tabsetPanel(type = "tabs", 
	        tabPanel("Instructions", 
	        	p("In 1953, Claude Shannon published a short",
		    	tags$a("memorandum", href="https://dl.dropboxusercontent.com/u/29036005/shannon-mind-reading.pdf"), 
		    	"at Bell Laboratories describing a \"mind-reading\" machine he had built. The machine plays a simple game: a human adversary repeatedly chooses \"left\" or \"right\", each time trying to keep the machine from predicting his or her choice. The machine keeps score and gives itself a point if it plays correctly, and gives the player a point the player keeps correctly. The machine tries to detect and exploit certain simple patterns in the adversary's play (using 16",
		    	tags$em("bits"), 
		    	" of memory!)."
			    ),
			    p("Though the story of the machine has been passed down in engineering lore, the original memorandum says nothing about how well it played. Here is your opportunity to play against a simple R implementation of the machine."),
			    wellPanel(p("To play:"),
			    tags$ul(list(
			    	tags$li("Keep clicking", em("Left"), " or ", em("Right"), " and try to keep the machine from outguessing you (the score will update automatically)."),
			    	tags$li("When you are ready to analyze your performance, click \"Done\" and visit the tabs on the right to view statistics from your play.)")
			    ))),
			    p(em("Tips"), "...")
			),
	        tabPanel("Running p-value", verbatimTextOutput("summary")), 
	        tabPanel("Data-based predictions only", tableOutput("table")),
	        tabPanel("Your predictability", tableOutput("table2"))
	      )
	    )
	)
))
