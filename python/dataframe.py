#!/usr/bin/python

'''

dataframe.py, provides methods to alter, and return a dataframe.

'''

import sys
import json
import pandas as pd
import numpy as np
from datetime import datetime


class Dataframe:
    def __init__(self, fp):
        '''

        define class variables

        '''

        self.df = pd.read_csv(fp)
        self.df = self.df.applymap(lambda x: x.strip() if type(x) is str else x)

    def to_integer(self, column):
        '''

        convert column to integer.

        '''

        self.df[column] = pd.to_numeric(self.df[column].str.replace(',', ''))

    def to_lower(self):
        '''

        convert dataframe to lowercase, and strip leading + trailing whitespace.

        '''

        self.df = self.df.apply(lambda x: x.astype(str).str.lower())

    def drop_na(self):
        '''

        drop rows if any cell contain NaN.

        '''

        self.df.dropna(inplace=True)

    def remove_cols(self, cols):
        '''

        cols, list of column names to be removed.

        '''

        self.df.drop(cols, axis=1, inplace=True)

    def rename_col(self, cols):
        '''

        cols, replace column oldname, with newname having the form:

            {'oldName1': 'newName1', 'oldName2': 'newName2'}

        '''

        if isinstance(cols, dict):
            self.df.rename(columns=cols, inplace=True)
        elif isinstance(cols, str):
            self.df.rename(columns=json.loads(cols), inplace=True)

    def split_remove(self, column, delimiter):
        '''

        remove all characters after delimiter

        '''

        self.df[column] = [x.split(delimiter, 1)[0] for x in self.df[column].astype(str)]

    def reformat_date(self, column, format='%Y-%m'):
        '''

        remove all characters after delimiter

        '''

        self.df[column] = pd.to_datetime(
            self.df[column],
            errors='coerce'
        ).dt.strftime(format)

    def get_df(self):
        '''

        return given dataframe.

        '''

        return self.df

    def replace_val(self, column, old, new):
        '''

        replace old value with new value in specified column.

        '''

        self.df[column].replace(old, new, inplace = True)