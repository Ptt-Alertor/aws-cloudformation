import os
from datetime import date, timedelta
import urllib3
import json
import logging

logging.getLogger().setLevel(logging.INFO)


def send_delete(url, data={}):
    http = urllib3.PoolManager()
    body = json.dumps(data).encode('utf-8')
    response = http.request('DELETE', f'https://{url}', body=body,
                            headers={'Content-type': 'application/json'})
    if response.status >= 300 and response.status < 200:
        logging.error(response)
        return False
    return True


def lambda_handler(event, context):
    elastic_search_endpoint = os.environ['ELASTICSEARCH_ENDPOINT']
    retention_days = int(os.environ['RETENTION_DAYS'])
    deleteDate = date.today() - timedelta(days=retention_days)
    indice = 'cwl-' + deleteDate.strftime('%Y.%m.%d')
    url = elastic_search_endpoint + "/" + indice
    logging.info(url)
    if not send_delete(url):
        exit(1)
