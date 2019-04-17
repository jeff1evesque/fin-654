# fin-654

This project originally desired to study companies recently hacked, otherwise made vulnerable. However, as the course progressed, the analysis mainly focused on the general portfolio. Furthermore, the data covers a span less than 1.5 years, a constraint of the original data and original project aspiration:

* [Privacy Rights Clearinghouse](https://www.privacyrights.org/data-breaches)
* [World's Biggest Data Breaches & Hacks](https://informationisbeautiful.net/visualizations/worlds-biggest-data-breaches-hacks/)

Specifically, the above data was merged with historical stock prices. To reduce development, corresponding [stock data](https://github.com/jeff1evesque/fin-654/tree/master/data) was collected locally. However, an [untested feature](https://github.com/jeff1evesque/fin-654/blob/8d3606fee63c0b4c9ad16f633c73c6287211a94b/app.R#L315) was coded, allowing stock prices to be collected from [quandl](https://www.quandl.com/).

## Dashboard

The dashboard shows from the select companies with corresponding overall variance. Since variance is a measure of risk, the smallest overall variance is preferred:

![dashboard](https://user-images.githubusercontent.com/2907085/56251148-63ebf800-6080-11e9-9fdb-d7e7f65551bb.PNG)

## Exploratory

Some exploratory analysis was conducted on individual company stock. Specifically, timeseries plots were made, as well as [autocorrelation function](https://en.wikipedia.org/wiki/Autocorrelation) (ACF), and [partial autocorrelation function](https://people.duke.edu/~rnau/411arim3.htm) (PACF) plots. However, later analysis focused on the collective portfolio, rather than individual timeseries. Furthermore, if more time were to be allocated to this project, an overall ACF and PACF would be computed, and would [determine](https://www.youtube.com/watch?v=R-oWTWdS1Jg) autoregression (AR), and the moving average (MA) components to the below Arima model.

## General Pareto Distribution

A [general pareto distribution](https://www.mathworks.com/help/stats/examples/modelling-tail-data-with-the-generalized-pareto-distribution.html) (GPD) was computed as a risk measure for the overall portfolio. Though some components were visually minimized, the GPD was computed for the overall opening, closing, and general volume. Moreover, the [value at risk](https://github.com/jeff1evesque/fin-654/blob/master/resources/VAR.pdf) (VaR) is a measure of potential loss for a given portfolio, while the [expected shortfall](https://en.wikipedia.org/wiki/Expected_shortfall) (ES) is the average of all losses greater than the VaR. Both measures, are provided with the below GPD distributions:

![gpd](https://user-images.githubusercontent.com/2907085/56251301-13c16580-6081-11e9-8454-b964cae7a88e.PNG)

Since this project made some great simplifications, the portfolio was equally distributed (one share) among the selected stocks. Therefore, corresponding risk measures are significantly small.

**Note:** the user-interface allows different segments to be toggled. Additionally, content on the above VAR was borrowed from [Professor Damodaran](http://people.stern.nyu.edu/adamodar/), from the Stern School of Business at New York University.

## Efficient Frontier

A general [efficient frontier](https://www.youtube.com/watch?v=PiXrLGMZr1g) was created, along with the tangent markowitz model to signify the most efficient portfolio. Moreover, individual stocks were also plotted:

![markowitz](https://user-images.githubusercontent.com/2907085/56251438-9d713300-6081-11e9-8bdf-13d849ceee5c.PNG)

## Arima Model

A general [arima model](https://machinelearningmastery.com/arima-for-time-series-forecasting-with-python/) was computed for the overall portfolio:

![arima](https://user-images.githubusercontent.com/2907085/56251496-d9a49380-6081-11e9-8e7a-68c598532104.PNG)

A [stationarity](https://www.youtube.com/watch?v=ZIWyGjrAlks) test using the [augmented dickey fuller test](https://www.youtube.com/watch?v=X8nGZ2UCJsk) was implemented. Moreover, ACF and PACF measures provides suggestive values for the AR and MA arguments, to help reduce [seasonal patterns](https://github.com/jeff1evesque/fin-654/blob/master/resources/Slides_on_ARIMA_models--Robert_Nau.pdf). Furthermore, a general [mean squared error](https://en.wikipedia.org/wiki/Mean_squared_error) (MSE) was computed to allow comparison with the below recurrent neural network.

**Note:** the training data was minimized, and identical to the below RNN variant.

## Recurrent Neural Network

A [long-short-term-memory](https://www.youtube.com/watch?v=QuELiw8tbx8) (LSTM) recurrent neural network was created:

![lstm](https://user-images.githubusercontent.com/2907085/56251601-2be5b480-6082-11e9-8f95-4de0a169ac06.PNG)

**Note:** the training data was minimized, and identical to the above Arima model variant.
