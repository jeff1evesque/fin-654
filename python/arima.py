#!/usr/bin/python

from statsmodels.tsa.arima_model import ARIMA
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split


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

        self.train, self.test = train_test_split(self.data, test_size=test_size)
        train_set = self.train
        test_set = self.test

        self.df_train = pd.DataFrame(train_set)
        self.df_test = pd.DataFrame(test_set)

    def get_data(self):
        '''

        get current train and test data.

        '''

        return(self.df_train, self.df_test)

    def train_model(self, iterations, order=(1,1,1)):
        '''

        train arima model.

        @order, (p,q,d) arguments can be defined using acf (MA), and pacf (AR)
            implementation. Corresponding large significant are indicators.

        Note: requires 'split_data' to be executed.

        '''

        self.history = [x for x in self.df_train]
        predictions = list()
        differences = list()
        rolling = list()

        for t in range(iterations):
            model = ARIMA(history, order=order)
            model_fit = model.fit(disp=0)
            output = model_fit.forecast()
            yhat = output[0]
            predictions.append(yhat)

            #
            # observation: if current value doesn't exist from test, append current
            #     prediction, to ensure successive rolling prediction computed.
            #
            try:
                obs = self.df_test[t]
                differences.append({
                    'predicted': float(yhat),
                    'expected': obs,
                    'difference': abs(1-float(yhat)/obs)
                })

            except:
                obs = yhat
                rolling.append({'predicted': obs})

            self.history.append(obs)

        self.score = {
            'mse': mean_squared_error(self.df_test, predictions),
            'differences': differences,
            'rolling': rolling
        }

    def get_score(self):
        '''

        return scores generated via 'train_model'.

        '''

        return(self.score)

    def get_index(self):
        '''

        get dataframe row index.

        '''

        return(self.data.index.values)
