library(shiny)

shinyUI(fluidPage(

	tags$style(type='text/css', ".game-button { width: 48%; }"),

    titlePanel("A Mind-Reading (?) Machine, Analyzed"),

    sidebarLayout(
    	sidebarPanel(
    		tags$button(id = "tail", type = "button", class = "btn action-button game-button", "Left"),
	    	tags$button(id = "head", type = "button", class = "btn action-button game-button", "Right"),
	    	br(),
	    	textOutput("message", h2),
	    	p("Computer: ", textOutput("computerScore", span), " - You: ", textOutput("playerScore", span)),
	    	conditionalPanel(
	    		condition="output.computerWin === 'T'",
	    		div(class="alert alert-error alert-block", h4("HA! Point for me!"))
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
			    	tags$li("When you are ready to analyze your performance, visit the tabs on the right to view statistics from your play.")
			    ))),
			    p(em("Hint:"), "To get the most out of the game, treat the machine as if it's really trying to outsmart you. (It would work well as a party game, where slightly inebriated people could get \"into\" trying to keep the machine from achieving the higher score.) The machine cannot systematically beat a player who plays randomly without regard to whether he or she is \"winning\" or \"losing\". I have found that if you play in the \"party game\" spirit, after 50 or 100 plays, the one-sided binomial test shows that the machine is winning >50% of the matches.")
			),
	        tabPanel("Running p-value", 
	        	p("This analysis attempts to show whether the program can predict your behavior better than chance. Below is a graph against trial ", em("n"), " of p-values of a one-sided binomial test of the hypothesis that, by trial ", em("n"), ", the computer had predicted your behavior better than chance. (Specifically, it shows the probability that", em("n"), " fair coinflips would predict your first ", em("n"), " choices as well or better than the computer did.) For context, the running game score is also shown (computer's score in red, your score in green"),
	        	p("The regions highlighted in darker gray indicate trials where the computer's prediction was based in some way on your previous behavior. For trials in light gray regions, predictions were chosen randomly (with equal probability for left or right)."),
	        	conditionalPanel(
	        		condition = "output.overallPlotAvailable === 'F'",
	        		div(class="alert alert-info alert-block", 
	        			h4("No data yet"),
	        			p("You haven't played the game long enough (or you've reloaded the page), so there's no data to show yet.")
	        		)
	        	),	        		
	        	plotOutput("overallScoreAndPvalue")
	        ),
	        tabPanel("Data-based predictions only", 
	        	p("This analysis shows a subset of trials in which the computer made its prediction non-randomly, using data about your past behavior. This corresponds to the highlighted trials in the \"Running p-value\" tab."),
	        	p("It contains a running p-value like that the one shown in that tab, but only tests the computer's ability to predict your choice ", em("when it thinks it has data to make a prediction"), ". The score shown is the score ", em("differential"), " achieved in these trials"),
	        	p("This is useful because the overall predictions are noisy--even when the computer doesn't think it can make a data-driven decision, it still has to make some choice."),
	        	conditionalPanel(
	        		condition = "output.informedPlotAvailable === 'F'",
	        		div(class="alert alert-info alert-block", 
	        			h4("No data yet"),
	        			p("You haven't played the game long enough (or you've reloaded the page), so there's no data to show yet.")
	        		)
	        	),
	        	plotOutput("informedScoreAndPvalue")),
	        tabPanel("Your predictability", 
	        	p("This analysis gets at how the algorithm operates (and how the 1953 machine was able to get away with a 16-bit memory). Once the game is in progress, game state is reduced to one of 8 \"situations\" that encode the last 2 plays: player won (or lost), then played the same (or differently), and then won (or lost)."),
	        	p("This graph shows whether your behavior is especially biased in any of these cases. In actual operation, the machine bases its guess on your past behavior in only the previous two situations matching the current game situation. If you played them identically (either playing \"same\" both times, or \"different\" both times), it assumes you will repeat that choice on your next play."),
	        	plotOutput("playsBySituation")
	        )
	      )
	    )
	)
))
