#!/usr/bin/python

import math
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from keras.layers import Dropout
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split


class Lstm():
    '''

    apply lstm variant of recurrent neural network.

    '''

    def __init__(self, data, train=False, normalize_key=None):
        '''

        define class variables.

        '''

        if isinstance(data, dict):
            self.data = pd.DataFrame(data)
        else:
            self.data = data

        self.row_length = len(self.data)
        
        # convert column to dataframe index
        self.data.set_index('date', inplace=True)

        # convert dataframe columns to integer
        self.data.total = self.data.total.astype(int)

        # execute model
        self.split_data()

        if normalize_key:
            self.normalize_key = normalize_key
            self.normalize(self.data[normalize_key])
        else:
            self.normalize_key = None

        # train
        if train:
            self.train()
            self.predict_test()

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

    def normalize(self, timesteps=60):
        '''

        @train_set, must be the value column from the original dataframe.

        '''

        # scaling normalization
        self.sc = MinMaxScaler(feature_range = (0, 1))
        training_set_scaled = self.sc.fit_transform(self.df_train[[self.normalize_key]])

        X_train = []
        y_train = []
        for i in range(timesteps, self.row_length):
            X_train.append(training_set_scaled[i-timesteps:i, 0])
            y_train.append(training_set_scaled[i, 0])

        X_train, self.y_train = np.array(X_train), np.array(y_train)

        # Reshaping
        self.X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))

    def train_model(self, epochs=50):
        '''

        train lstm model.

        '''

        # Initialize RNN
        self.regressor = Sequential()

        # Adding the first LSTM layer and some Dropout regularisation
        self.regressor.add(LSTM(
            units = 50,
            return_sequences = True,
            input_shape = (self.X_train.shape[1], 1)
        ))
        self.regressor.add(Dropout(0.2))

        # Adding a second LSTM layer and some Dropout regularisation
        self.regressor.add(LSTM(
            units = 50,
            return_sequences = True
        ))
        self.regressor.add(Dropout(0.2))

        # Adding a third LSTM layer and some Dropout regularisation
        self.regressor.add(LSTM(
            units = 50,
            return_sequences = True
        ))
        self.regressor.add(Dropout(0.2))

        # Adding a fourth LSTM layer and some Dropout regularisation
        self.regressor.add(LSTM(units = 50))
        self.regressor.add(Dropout(0.2))

        # Adding the output layer
        self.regressor.add(Dense(units = 1))

        # Compiling the RNN
        self.regressor.compile(optimizer = 'adam', loss = 'mean_squared_error')

        # Fitting the RNN to the Training set
        self.regressor.fit(
            self.X_train,
            self.y_train,
            epochs = epochs,
            batch_size = 32
        )

    def predict_test(self, timesteps=60):
        '''

        generate prediction using hold out sample.

        '''

        dataset_total = pd.concat(
            (self.df_train, self.df_test),
            axis = 0
        )
        inputs = dataset_total[len(dataset_total) - len(self.df_test) - timesteps:].values
        inputs = inputs.reshape(-1, 1)
        inputs = self.sc.transform(inputs)
        X_test = []

        for i in range(timesteps, self.row_length):
            X_test.append(inputs[i-timesteps:i, 0])

        X_test = np.array(X_test)
        X_test = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], 1))

        predicted = self.regressor.predict(X_test)
        predicted = self.sc.inverse_transform(predicted)

        return(pd.DataFrame(predicted))

    def get_actual(self):
        '''

        get actual values from hold out sample.

        '''

        return(self.test)

    def get_model(self):
        '''

        get trained lstm model.

        '''

        return(self.regressor)

