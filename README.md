# fin-654

This project was originally motivated on the analysis of stocks who have recently been hacked, otherwise made vulnerable. However, as the course progressed, the analysis focused mainly on general portfolio measures.

## Dashboard

The dashboard shows from the select companies, which contains the least variance:

![dashboard](https://user-images.githubusercontent.com/2907085/56251148-63ebf800-6080-11e9-9fdb-d7e7f65551bb.PNG)

## Exploratory

Some exploratory analysis was conducted on individual company stock. Specifically, timeseries plots were made, as well as [autocorrelation function](https://en.wikipedia.org/wiki/Autocorrelation) (ACF), and [partial autocorrelation function](https://people.duke.edu/~rnau/411arim3.htm) (PACF) plots. However, later analysis focused on the collective portfolio, rather than individual timeseries. Furthermore, if more time were to be allocated to this project, an overall ACF and PACF would be computed, and would [determine](https://www.youtube.com/watch?v=R-oWTWdS1Jg) autoregression (AR), and the moving average (MA), and components to the below Arima model.

## General Pareto Distribution

A [general pareto distribution](https://www.mathworks.com/help/stats/examples/modelling-tail-data-with-the-generalized-pareto-distribution.html) (GPD) was computed as a risk measure for the overall portfolio. Though some components were minimized, the GPD was computed for the overall opening, closing, and general volume. Moreover, the [value at risk](https://github.com/jeff1evesque/fin-654/blob/master/resources/VAR.pdf) (VaR) is a measure of potential loss for a given portfolio, while the [expected shortfall](https://en.wikipedia.org/wiki/Expected_shortfall) (ES) is the average of all losses greater than the VaR. Both measures, are provided with the below GPD distributions:

![gpd](https://user-images.githubusercontent.com/2907085/56251301-13c16580-6081-11e9-8454-b964cae7a88e.PNG)

Since this project made some great simplifications, the portfolio was equally distributed with one stock. Therefore, corresponding risk measures are significantly small.

**Note:** the user-interface allows different segments to be toggled. Additionally, content on the above VAR was borrowed from [Professor Damodaran](http://people.stern.nyu.edu/adamodar/), from the Stern School of Business at New York University.

## Efficient Frontier

A general [efficient frontier](https://www.youtube.com/watch?v=PiXrLGMZr1g) was created, along with the tangent markowitz model to signify the most efficient portfolio. Moreover, individual stocks were also plotted:

![markowitz](https://user-images.githubusercontent.com/2907085/56251438-9d713300-6081-11e9-8bdf-13d849ceee5c.PNG)

## Arima Model

A general [arima model](https://machinelearningmastery.com/arima-for-time-series-forecasting-with-python/) was computed for the overall portfolio:

![arima](https://user-images.githubusercontent.com/2907085/56251496-d9a49380-6081-11e9-8e7a-68c598532104.PNG)

Due to simplicity, [stationarity](https://www.youtube.com/watch?v=ZIWyGjrAlks) was not tested, and the arima arguments were not defined on the basis of ACF and PACF measures. This could likely be the reason for a relatively higher [mean squared error](https://en.wikipedia.org/wiki/Mean_squared_error) (MSE) compared to the below LSTM implementation.

**Note:** the training data was minimized, and identical to the below RNN variant.

## Recurrent Neural Network

A [long-short-term-memory](https://www.youtube.com/watch?v=QuELiw8tbx8) (LSTM) recurrent neural network was created:

![lstm](https://user-images.githubusercontent.com/2907085/56251601-2be5b480-6082-11e9-8f95-4de0a169ac06.PNG)

**Note:** the training data was minimized, and identical to the above Arima model variant.
