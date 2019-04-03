#!/usr/bin/python

import pandas as pd
import numpy as np
from keras.models import Sequential
from keras.layers import LSTM,Dense
from sklearn.preprocessing import MinMaxScaler
from keras.models import load_model
from sklearn.model_selection import train_test_split


class Lstm():
    '''

    apply lstm variant of recurrent neural network.

    '''

    def __init__(self, data):
        '''

        define class variables.

        '''

        self.data = data
        self.look_back = 40
        self.forward_days = 10
        self.num_periods = 20
        self.num_companies = len(self.data)

        for df in self.data:
            df.set_index('date', inplace=True)

        # execute model
        self.normalize()
        self.split_data()

    def normalize(self):
        '''

        normalize current data.

        '''

        scl = MinMaxScaler()
        args = [df.values.reshape(df.shape[0],1) for df in self.data]
        self.array = scl.fit_transform(
            np.concatenate(set(arg for arg in args), axis=1)
        )

    def utility_split(self, data, jump=1):
        '''

        utility function used by 'split_data'.

        '''

        X,Y = [],[]
        for i in range(0, len(data) - self.look_back - self.forward_days + 1, jump):
            X.append(data[i:(i+self.look_back)])
            Y.append(data[(i+self.look_back):(i+self.look_back+self.forward_days)])
        return(np.array(X), np.array(Y))

    def split_data(self, test_size=0.20):
        '''

        split data into train and test.

        Note: this requires execution of 'self.normalize'.

        '''

        division = len(self.array) - self.num_periods * self.forward_days
        array_test = self.array[division-self.look_back:]
        array_train = self.array[:division]
        X_test,y_test = utility_split(array_test)
        y_test = np.array([list(a.ravel()) for a in y_test])
        X,y = utility_split(array_train)
        y = np.array([list(x.ravel()) for x in y])
        self.X_train, self.X_validate, self.y_train, self.y_validate = train_test_split(
            X,
            y,
            test_size=test_size,
            random_state=42
        )

    def train(self, num_first_layer=200, num_second_layer=100, epochs=50):
        '''

        train lstm model.

        '''

        model = Sequential()
        model.add(LSTM(
            num_first_layer,
            input_shape=(self.look_back, self.num_companies),
            return_sequences=True
        ))
        model.add(LSTM(
            num_second_layer,
            input_shape=(num_first_layer, 1)
        ))
        model.add(Dense(forward_days * self.num_companies))
        model.compile(loss='mean_squared_error', optimizer='adam')

        self.train = model.fit(
            self.X_train,
            self.y_train,
            epochs=epochs,
            validation_data=(self.X_validate, self.y_validate),
            shuffle=True,
            batch_size=1,
            verbose=2
        )

    def get_model(self):
        '''

        get trained lstm model.

        '''

        return(self.train)
