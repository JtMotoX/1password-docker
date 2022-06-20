#!/bin/sh

# THIS IS DESIGNED TO BE SOURCED AT THE TOP OF YOUR APPLICATIONS DOCKER ENTRYPOINT
# example: . /tmp/op-vars.sh

command -v curl >/dev/null || { echo "Curl is required"; exit 1; }

env >/tmp/env.txt
while IFS= read -r line; do
	val=${line#*=}
	key=${line%%=*}
	regexp="^OP:([^:]*):(.*)"
	if echo "${val}" | grep -E "${regexp}" >/dev/null; then
		vault_name=$(echo "${val}" | sed -E "s/${regexp}/\1/")
		vault_item_title=$(echo "${val}" | sed -E "s/${regexp}/\2/")
		response=$(curl -sS -k -X POST -H "content-type: application/json" -d "{\"vault_name\": \"${vault_name}\", \"item_title\": \"${vault_item_title}\", \"auth\": \"${OP_AUTH}\"}" "${OP_ENDPOINT}/get-password" || echo "")
		RESPONSE_ERROR="$(echo "${response}" | grep -o '"error":"[^"]*' | grep -o '[^"]*$' || echo "")"
		if [ "${RESPONSE_ERROR}" != "" ]; then
			echo "ERROR: ${RESPONSE_ERROR}"
			exit 1
		fi
		RESPONSE_PASSWORD="$(echo "${response}" | grep -o '"password":"[^"]*' | grep -o '[^"]*$' || echo "")"
		if [ "${RESPONSE_PASSWORD}" = "" ]; then
			echo "ERROR: Unable to get 1Password value for '${key}'"
			exit 1
		fi
		export ${key}="${RESPONSE_PASSWORD}"
	fi
done < /tmp/env.txt
rm -f /tmp/env.txt
