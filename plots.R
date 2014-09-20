cumbinom <- function (wins) {
	sapply(1:length(wins), function(n) {
    	binom.test(sum(wins[1:n]), n, 0.5, alternative='greater')$p.value
	})
}

plotOverallScoreAndPvalue <- function(history) {
	# get the cumulative scores
	df <- with(history, data.frame(
		    trial         = seq_along(predictions), 
		    computerScore = cumsum(predictions==choices), 
		    playerScore   = cumsum(predictions!=choices)
		))

	df <- melt(df, id.vars=c('trial'))
	df <- cbind(df, type='score')

	# add the cumulative pvalues
	wins <- history$predictions == history$choices
	pHistory <- cumbinom(wins) 

	df <- rbind(df, data.frame(
		trial    = seq_along(pHistory), 
		variable = 'pvalue', 
		value    = pHistory, 
		type     = 'pvalue'
	))

	g <- ggplot(df, 
			aes(
				x     = trial, 
				y     = value
			)
		) + 
		facet_grid(type ~ ., scale = 'free') + 
		geom_step(aes(color = variable)) + 
		scale_color_hue(labels = c("Computer's score", "Your score", "P(better than random)")) +
		geom_rect(
	    	aes(
				ymin  = -Inf, 
				ymax  = Inf, 
				xmin  = trial - 0.5, 
				xmax  = trial + 0.5, 
				alpha = history$predictionInformed[trial] & (variable == 'pvalue' | variable == 'playerScore')
			),
			color=alpha('black', 0)
		) + 
		scale_alpha_manual(values = c(0, 0.15), labels=c("Random", "From past behavior")) +
		guides(
			color = guide_legend(title=NULL), 
			alpha = guide_legend(title="Prediction")
		) + 
		xlab("Trial") + 
		ylab(NULL) + 
		ggtitle("Running score and p-value for one-sided binomial\ntest of P(computer guesses correctly) > 0.5")
}



plotInformedScoreAndPvalue <- function() {

}

plotPlaysBySituation <- function() {

}

