#!/usr/bin/python


def name_to_ticker(series, refs, names, targets):
    '''

    return subset dataframe premised on the 'names' column,
    which must contain values using the provided 'series'..

    @series, list of company names to be converted
    @refs, dataframe containing references for conversion
        @names, column with name references
        @targets, column with desired references

    '''

    r = refs[[names, targets]]
    return(r.loc[r[names].isin(series)])
