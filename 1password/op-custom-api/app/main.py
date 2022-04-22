#!/usr/bin/env python

from flask import Flask, json, request
from waitress import serve
import requests
import jmespath
import os

app = Flask(__name__)

OP_ENDPOINT = os.getenv('OP_ENDPOINT')
OP_API_TOKEN = os.getenv('OP_API_TOKEN')

@app.route('/get-password', methods=['GET', 'POST'])
def get_password():
	# GET REQUEST DATA
	request_data = request.json
	auth = request_data["auth"]
	vault_name = request_data["vault_name"]
	item_title = request_data["item_title"]

	# VALIDATE AUTH
	f = open('/privileges.json')
	privileges = json.load(f)
	PRIV_DATA = jmespath.search('[?auth==`{}`] | [0]'.format(auth), privileges)
	if PRIV_DATA is None: return("Authentication Failed")
	ITEMS_ALLOWED = jmespath.search('access[?vault==`{}`] | [0].items'.format(vault_name), PRIV_DATA)
	if ITEMS_ALLOWED is None: return("Access denied")
	if item_title not in ITEMS_ALLOWED: return("Access denied")

	# GET VAULT ID
	r = requests.get(url = "{}/v1/vaults".format(OP_ENDPOINT), headers={'Authorization': 'Bearer {}'.format(OP_API_TOKEN)})
	VAULT_RESPONSE = r.json()
	VAULT_ID = jmespath.search('[?name==`{}`] | [0].id'.format(vault_name), VAULT_RESPONSE)

	# GET ITEM ID
	r = requests.get(url = "{}/v1/vaults/{}/items".format(OP_ENDPOINT, VAULT_ID), headers={'Authorization': 'Bearer {}'.format(OP_API_TOKEN)})
	ITEMS_RESPONSE = r.json()
	ITEM_ID = jmespath.search('[?title==`{}`] | [0].id'.format(item_title), ITEMS_RESPONSE)

	# GET ITEM PASSWORD VALUE
	r = requests.get(url = "{}/v1/vaults/{}/items/{}".format(OP_ENDPOINT, VAULT_ID, ITEM_ID), headers={'Authorization': 'Bearer {}'.format(OP_API_TOKEN)})
	ITEM_RESPONSE = r.json()
	ITEM_PASSWORD = jmespath.search('fields[?id==`password`] | [0].value', ITEM_RESPONSE)

	# RETURN ITEM PASSWORD VALUE
	return ITEM_PASSWORD


if __name__ == "__main__":
	serve(app, host='0.0.0.0', port=5000, url_scheme='https')
