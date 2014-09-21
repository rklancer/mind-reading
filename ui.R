library(shiny)

shinyUI(fluidPage(

	tags$style(type='text/css', ".game-button { width: 5em; margin-right: 1em }"),

    titlePanel("A Mind-Reading (?) Machine, Analyzed"),

    sidebarLayout(
    	sidebarPanel(
    		tags$button(id = "tail", type = "button", class = "btn action-button game-button", "Left"),
	    	tags$button(id = "head", type = "button", class = "btn action-button game-button", "Right"),
	    	br(),
	    	textOutput("message", h2),
	    	p("score: ", textOutput("computerScore", span), " - ", textOutput("playerScore", span)),
	    	conditionalPanel(
	    		condition="output.computerWin === 'T'",
	    		div(class=list("alert", "alert-block"), h4("Point for me!"))
	    	)
    	),
	    mainPanel(
	      tabsetPanel(type = "tabs", 
	        tabPanel("Instructions", 
	        	p("In 1953, Claude Shannon published a short Bell Laboratories ",
		    	tags$a("memorandum", href="https://dl.dropboxusercontent.com/u/29036005/shannon-mind-reading.pdf"), 
		    	" describing a \"mind-reading\" machine he had built. The machine plays a simple game: a human adversary repeatedly chooses \"left\" or \"right\", each time trying to keep the machine from predicting his or her choice. The machine keeps score and gives itself a point if it guesses the player's move correctly, and gives the player a point if it guesses incorrectly. The machine works by detecting and exploiting certain simple patterns in the adversary's play (using 16",
		    	tags$em("bits"), 
		    	" of memory)."
			    ),
			    p("Though the story of the machine has been passed down in engineering lore, the original memorandum says nothing about how well it played. Here is your opportunity to play against a simple R implementation of the machine."),
			    wellPanel(p("To play:"),
			    tags$ul(list(
			    	tags$li("Keep clicking", em("Left"), " or ", em("Right"), " and try to keep the machine from outguessing you (the score will update automatically)."),
			    	tags$li("When you are ready to analyze your performance, visit the tabs on the right to view statistics from your play.)")
			    ))),
			    p(em("Hint:"), "To get the most out of the game, treat the machine as if it's really trying to outsmart you. (It would work well as a party game, where slightly inebriated people could get \"into\" trying to keep the machine from achieving the higher score.) The machine cannot systematically beat a player who plays randomly without regard to whether he or she is \"winning\" or \"losing\". I have found that if you play in the \"party game\" spirit, after 50 or 100 plays, the one-sided binomial test shows that the machine is winning >50% of the matches.")
			),
	        tabPanel("Running p-value", 
	        	conditionalPanel(
	        		condition = "output.overallPlotAvailable === 'F'",
	        		div(class="alert alert-info", 
	        			h4("No data yet"),
	        			p("You haven't played the game (or you've reloaded the page), so there's no data to show yet.")
	        		)
	        	),
	        	plotOutput("overallScoreAndPvalue")
	        ),
	        tabPanel("Data-based predictions only", plotOutput("informedScoreAndPvalue")),
	        tabPanel("Your predictability", plotOutput("playsBySituation"))
	      )
	    )
	)
))
