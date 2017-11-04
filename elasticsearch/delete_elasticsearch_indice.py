import os
from datetime import date, timedelta

def lambda_handler(event, context):
    elastic_search_endpoint = os.environ['ELASTICSEARCH_ENDPOINT']
    deleteDate = date.today() - timedelta(days=31)
    indice = 'cwl-' + deleteDate.strftime('%Y.%m.%d')
    url = elastic_search_endpoint + indice
    cmd = 'curl -XDELETE ' + url
    r = os.popen(cmd).read()
    return r