#!/bin/sh -x

bundle exec rake nlcommons:person_country_list > person_country_list.xls
bundle exec rake nlcommons:person_country_adj_matrix >  person_country_adj_matrix.xls
bundle exec rake nlcommons:person_interest_adj_matrix > person-interest-adj-matrix.xls
bundle exec rake nlcommons:person_model_adj_matrix > person-model-adj-matrix.xls
