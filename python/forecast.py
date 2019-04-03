#!/usr/bin/python

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

    def __init__(self, data, train=False):
        '''

        define class variables.

        '''

        self.data = data
        for df in self.data:
            df.set_index('date', inplace=True)

        # execute model
        self.split_data()
        self.normalize()

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
        train_set = self.train['open']
        test_set = self.test['open']

        self.df_train = pd.DataFrame(train_set)
        self.df_test = pd.DataFrame(test_set)

    def normalize(self):
        # scaling normalization
        self.sc = MinMaxScaler(feature_range = (0, 1))
        training_set_scaled = self.sc.fit_transform(self.df_train)

        # Creating a data structure with 60 timesteps and 1 output
        X_train = []
        y_train = []
        for i in range(60, 1258):
            X_train.append(training_set_scaled[i-60:i, 0])
            y_train.append(training_set_scaled[i, 0])
        X_train, self.y_train = np.array(X_train), np.array(y_train)

        # Reshaping
        self.X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))

    def train(self, epochs=50):
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

    def predict_test(self):
        dataset_total = pd.concat(
            (self.train['open'], self.test['open']),
            axis = 0
        )
        inputs = dataset_total[len(dataset_total) - len(self.test) - 60:].values
        inputs = inputs.reshape(-1,1)
        inputs = self.sc.transform(inputs)
        X_test = []

        for i in range(60, 80):
            X_test.append(inputs[i-60:i, 0])

        X_test = np.array(X_test)
        X_test = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], 1))
        predicted_stock_price = regressor.predict(X_test)
        predicted_stock_price = self.sc.inverse_transform(predicted_stock_price)

        return(pd.DataFrame(predicted_stock_price))

    def get_model(self):
        '''

        get trained lstm model.

        '''

        return(self.regressor)

