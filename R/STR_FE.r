#' Studentized residual by leave-one-out analysis by the fixed-effect model
#'
#' @param y A vector of the outcome measure estimates (e.g., MD, SMD, log OR, log HR)
#' @param v A vector of the variance estimates of outcome measures
#' @param B The number of bootstrap (default=2000)
#' @return Studentized residual, bootstrap 2.5th and 97.5the percentiles (list)
#' @export

STR_FE <- function(y, v, B=2000, alpha=0.95){

	reml1 <- ML_FE(y,v)

	mu0 <- reml1$mu
	v0 <- v + reml1$V0

	n <- length(y)
	psi <- numeric(n)

	for(i in 1:n){
	
		y_i <- y[setdiff(1:n,i)]
		v_i <- v[setdiff(1:n,i)]
	
		reml_i <- ML_FE(y_i,v_i)
		
		W0_i <- (v + reml_i$V0)^-1
		v_psi_i <- (W0_i[i])^-1 + sum(W0_i[-i])^-1
	
		psi[i] <- (y[i] - reml_i$mu) / sqrt(v_psi_i)
		
	}
                              
	psi.b <- matrix(numeric(n*B),B)

	for(b in 1:B){
	
		y.b <- rnorm(n, mean=mu0, sd=sqrt(v0))
		
		for(i in 1:n){
	
			y_i <- y.b[setdiff(1:n,i)]
			v_i <- v[setdiff(1:n,i)]
	
			reml_i <- ML_FE(y_i,v_i)
		
			W0_i <- (v + reml_i$V0)^-1
			v_psi_i <- (W0_i[i])^-1 + sum(W0_i[-i])^-1
	
			psi.b[b,i] <- (y.b[i] - reml_i$mu) / sqrt(v_psi_i)

		}
	
	}
		
	Q1 <- Q2 <- numeric(n)
	
	alpha1 <- (1 - alpha)/2
	alpha2 <- 1 - alpha1
		
	for(i in 1:n){
	
		X.b <- psi.b[,i]
		#P[i] <- QT(X.b, abs(psi[i]))
		Q1[i] <- as.numeric(quantile(X.b,alpha1))
		Q2[i] <- as.numeric(quantile(X.b,alpha2))
	
	}

	id <- 1:n
	R <- data.frame(id,psi,Q1,Q2)
	R <- R[rev(order(abs(psi))),]

	return(R)

}
