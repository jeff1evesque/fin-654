#!/usr/bin/python

import pandas_datareader as pdr
from datetime import datetime


def get_timeseries(symbol):
    '''

    get historical timeseries of provided symbol.

    '''

    return(pdr.get_data_yahoo(symbol))

#    if start and end:
#        return(
#            pdr.get_data_yahoo(
#                symbols=symbol
#            )
#        )
#    )
#
#    else:
#        return(pdr.get_data_yahoo(symbols=symbol))

