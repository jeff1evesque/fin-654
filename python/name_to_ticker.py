#!/usr/bin/python


def name_to_ticker(series, ref, col_1, col_2):
    '''

    convert list of company names to list of tickers.

    @col_1, column converted to index in dict
    @col_2, column converted to value in dict

    '''

    references = ref[[col_1, col_2]].set_index(col_1).to_dict()
    return([x if x not in references else references[x] for x in series])
