#!/usr/bin/python

'''

dataframe.py, provides methods to alter, and return a dataframe.

'''

import sys
import pandas as pd  


class Dataframe:
    def __init__(self, fp):
        '''

        define class variables

        '''

        self.df = pd.read_csv(fp, error_bad_lines=True, engine='python')

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
    
        self.df.rename(columns=cols, inplace=True)

    def split_remove(self, column, delimiter):
        '''

        remove all characters after delimiter

        '''

        self.df[column] = [x.split(delimiter, 1)[0] for x in self.df[column].astype(str)]

    def get_df(self):
        '''

        return given dataframe.

        '''

        return self.df
