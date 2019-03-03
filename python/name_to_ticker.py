#!/usr/bin/python


def name_to_ticker(series, refs, names, targets):
    '''

    convert list of 'names' to be converted to matching 'targets'.

    @series, list of company names to be converted
    @refs, dataframe containing references for conversion
        @names, column with name references
        @targets, column with target references

    '''

    r = refs[[names, targets]]
    return(r.loc[r[names].isin(series)][targets])
