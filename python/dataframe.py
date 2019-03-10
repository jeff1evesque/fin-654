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
    def __init__(self, data, dtype='csv'):
        '''

        define class variables

        '''

        if dtype == 'csv':
            self.df = pd.read_csv(data)

        elif dtype == 'json':
            self.df = pd.read_json(data)

        else:
            self.df = data

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

    def remove_rows(self, cols, items):
        '''

        remove any rows where specified column contains a specified string.

        @cols, list of columns to check for unacceptable strings.
        @items, list of unacceptable strings

        '''



    def remove_cols(self, cols):
        '''

        cols, list of column names to be removed.

        '''

        [self.df.drop(c, axis=1, inplace=True) for c in cols if c in self.df]

    def remove_rows(self, col, val, condition):
        '''

        remove row(s) where column satisfies condition.

        '''

        if condition == 'lt':
            [self.df.drop(i, axis=0, inplace=True) for i,r in self.df.iterrows() if r[col] < val]
        elif condition == 'lte':
            [self.df.drop(i, axis=0, inplace=True) for i,r in self.df.iterrows() if r[col] <= val]
        elif condition == 'gt':
            [self.df.drop(i, axis=0, inplace=True) for i,r in self.df.iterrows() if r[col] > val]
        elif condition == 'gte':
            [self.df.drop(i, axis=0, inplace=True) for i,r in self.df.iterrows() if r[col] >= val]
        elif condition == 'eq':
            [self.df.drop(i, axis=0, inplace=True) for i,r in self.df.iterrows() if r[col] == val]
        elif condition == 'neq':
            [self.df.drop(i, axis=0, inplace=True) for i,r in self.df.iterrows() if r[col] != val]
        elif condition == 'isin':
            # val, array dictating row removal
            if isinstance(val, str):
                items = [val]

            # col, an array of columns
            for c in col:
                if c in self.df:
                    self.df = self.df[~self.df[c].isin(items)]

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

    def replace_val(self, column, old_val, new_val):
        '''

        replace old value with new value in specified column.

        '''

        self.df[column].replace(old_val, new_val, inplace = True)

    def subset_on_col(self, column, subset):
        '''

        subset current dataframe, where specified column must 'contain' values
        from the 'subset' list.

        '''

        self.df = self.df[self.df[column].isin(subset)]

    def set_column(self, column, ref, new_key):
        '''

        for each 'column' value in the current dataframe, add an associated
        'ref.symbol' value in the 'new_key' column, if the corresponding
        'ref.name' exists in the current dataframe 'column'.

        @column, lookup column for current dataframe
        @ref, dataframe consisting of two lookup columns
            @name, similar to 'column' lookup type
            @symbol, the associated value to append if conditions are satisfied
        @new_key, column to append 'symbol' values if conditions are satisfied

        '''

        ## only 'ref' contains stock symbols
        results = []
        for i, x in self.df.iterrows():
            if x[column] in ref['name'].values:
                results.append(ref.loc[ref['name'] == x[column], 'symbol'].iloc[0])

        self.df[new_key] = results
