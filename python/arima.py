#!/usr/bin/python

from statsmodels.tsa.arima_model import ARIMA
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split
from statsmodels.tsa.stattools import adfuller
from statsmodels.tsa.seasonal import seasonal_decompose


class Arima():
    '''

    time series analysis using arima.

    '''

    def __init__(self, data, train=False, normalize_key=None):
        '''

        define class variables.

        '''

        if isinstance(data, dict):
            self.data = pd.DataFrame(data)
        else:
            self.data = data

        self.normalize_key = normalize_key
        self.row_length = len(self.data)

        # sort dataframe by date
        self.data['date'] = pd.to_datetime(self.data.date)
        self.data.sort_values(by=['date'], inplace=True)
        
        # convert column to dataframe index
        self.data.set_index('date', inplace=True)

        # convert dataframe columns to integer
        self.data.total = self.data.total.astype(int)

        # create train + test
        self.split_data()

        # train
        if train:
            self.train()

    def split_data(self, test_size=0.20):
        '''

        split data into train and test.

        Note: this requires execution of 'self.normalize'.

        '''

        # split without shuffling timeseries
        self.train, self.test = train_test_split(self.data, test_size=test_size, shuffle=False)
        self.df_train = pd.DataFrame(self.train)
        self.df_test = pd.DataFrame(self.test)

    def get_data(self, key=None, key_to_list=False):
        '''

        get current train and test data.

        '''

        if key:
            if key_to_list:
                return(self.df_train[key].tolist(), self.df_test[key].tolist())
            return(self.df_train[key], self.df_test[key])
        else:
            return(self.df_train, self.df_test)

    def train_model(self, iterations, order=[1,0,0]):
        '''

        train arima model.

        @order, (p,q,d) arguments can be defined using acf (MA), and pacf (AR)
            implementation. Corresponding large significant are indicators.

        Note: requires 'split_data' to be executed.

        '''

        actuals, predicted, rolling, differences = [], [], [], []
        self.history = self.df_train[self.normalize_key].tolist()

        #
        # @order, if supplied through R, elements will be interpretted as float.
        #     For example c(1, 1, 0) will be interpretted as [1.0, 1.0, 0.0] in
        #     python, which breaks iterable indices.
        #
        self.order = [int(i) for i in order]

        for t in range(iterations):
            model = ARIMA(self.history, order=self.order)
            model_fit = model.fit(disp=0)
            output = model_fit.forecast()
            yhat = float(output[0])
            predicted.append(yhat)

            #
            # observation: if current value doesn't exist from test, append current
            #     prediction, to ensure successive rolling prediction computed.
            #
            # @rolling, defined when 'iterations' exceeds original dataframe length,
            #     which defines the rolling predictions.
            #
            try:
                obs = float(self.df_test[self.normalize_key].tolist()[t])
                actuals.append(obs)
                differences.append(abs(1-(yhat/obs)))

            except:
                obs = yhat
                rolling.append(obs)

            # rolling prediction data
            self.history.append(obs)

        self.differences = (actuals, predicted, differences)
        self.mse = mean_squared_error(actuals, predicted)
        self.rolling = rolling

    def get_order(self):
        '''

        return arima (p,d,q) parameters.

        '''

        return(self.order)

    def get_mse(self):
        '''

        return mean squared error on trained arima model.

        '''

        return(self.mse)

    def get_difference(self, data=None, diff=0):
        '''

        return differenced timeseries.

        '''

        # default to arima (p,d,q) parameters
        if self.order:
            d  = self.order[1]
        else:
            d = diff

        # fallback on train/test split
        if data:
            original = data
        else:
            original = self.df_test[self.normalize_key].values

        # determine difference
        if int(diff) > 0:
            interval = int(d)
            differenced = []

            for i in range(interval, len(original)):
                value = original[i] - original[i - interval]
                differenced.append(value)

            return(differenced)

        return(original)

    def get_adf(self, data=None):
        '''

        return augmented dickey-fuller test:

            p-value > 0.05, fail to reject the null hypothesis, data has a unit
                unit root and is non-stationary.

            p-value <= 0.05, reject the null hypothesis, data does not have a
                unit root and is stationary.

        '''

        if not data and self.normalize_key:
            # ensure adf matches arima integrated difference
            if self.order:
                data = self.get_difference()

            else:
                data = self.df_test[self.normalize_key].values

        elif not data and not self.normalize_key:
            data = 'Provide valid list'

        return(adfuller(data))

    def get_differences(self):
        '''

        return differences between prediction against corresponding actual.

        '''

        return(self.differences)

    def get_rolling(self):
        '''

        return rolling predictions.

        '''

        return(self.rolling)

    def get_history(self):
        '''

        return entire timeseries history including rolling predictions.

        '''

        return(self.history)

    def get_index(self):
        '''

        get dataframe row index.

        '''

        return(self.data.index.values)

    def get_decomposed(self, series=None, model='additive', freq=1):
        '''

        decompose a time series into original, trend, seasonal, residual.

        '''

        if not series:
            series = self.data[self.normalize_key]

        result = seasonal_decompose(series, model=model, freq=freq)
        return(result.observed, result.trend, result.seasonal, result.resid)
