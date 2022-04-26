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
		vault_item_value=$(curl -s -k -X POST -H "content-type: application/json" -d "{\"vault_name\": \"${vault_name}\", \"item_title\": \"${vault_item_title}\", \"auth\": \"${OP_AUTH}\"}" "${OP_ENDPOINT}/get-password")
		if echo "${vault_item_value}" | grep -E '^ERROR: ' >/dev/null; then
			echo "Unable to get 1password value for '${key}' (${vault_item_value})"
			exit 1
		fi
		export ${key}="${vault_item_value}"
	fi
done < /tmp/env.txt
rm -f /tmp/env.txt
