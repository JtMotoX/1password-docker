# 1password-docker

This allows your docker containers to securely retrieve credentials from your 1password vault.  Instead of putting `FOO="secretPwd"` in your `.env` file, you can use `FOO="OP:myVault:myItemName"`. This prevents passwords from being stored in plain-text within your env_file.  This also prevents attackers from capturing credentials by running the `printenv` command within your container shell. 

Any process (your application) spawned from the entrypoint will see the environment variables with the values populated from 1password. Any process **not** spawned from the entrypoint (docker exec) will only see the 1password vault references. Because of this, no application changes are required.

## Before:
![Alt text](/sample-app/screenshots/1a.jpg?raw=true)
![Alt text](/sample-app/screenshots/1b.jpg?raw=true)

## After:
![Alt text](/sample-app/screenshots/2a.jpg?raw=true)
![Alt text](/sample-app/screenshots/2b.jpg?raw=true)


## Instructions:

1. To get started, [set up a Secrets Automation workflow](https://start.1password.com/integrations/connect) and get your Connect server credentials and first access token. Sign in to your 1Password account, and follow the onscreen instructions. It will provide you with the following:
	1. Your `1password-credentials.json` file. You will need to place this file in the [1password](./1password) directory **before** bringing up this instance. *Note: If you try to bring up the containers before creating this file, it will create a directory with this name which you will need to delete.*
	1. An access token. You will set this as the `OP_API_TOKEN=***` in the [1password/.env](./1password/.env) file.

1. Make a copy of the sample privileges file as [1password/privileges.json](./1password/privileges.json) and create any entries needed. You may want to have an entry for each application, so each application only has access to the vault items you specify. Each entry will have a unique auth token that you will need to create.  There are no requirements for the auth token (length, characters, etc..) *Note: If you try to bring up the containers before creating this file, it will create a directory with this name which you will need to delete.*

1. Generate an SSL Cert as [1password/op-reverse-proxy/cert/ssl.crt](1password/op-reverse-proxy/cert/ssl.crt) and [1password/op-reverse-proxy/cert/ssl.key](1password/op-reverse-proxy/cert/ssl.key)

1. `docker-compose up`

1. Configure your application to retrieve 1password credentials by choosing one of the following methods (see the [sample-app](./sample-app) for an example of each method):
	1. Replace the environment variables during entrypoint init
	1. Make rest-api calls:
		```bash
		curl -s -k -X POST -H 'content-type: application/json' -d '{"vault_name": "myVault","item_title": "myItemName","auth": "privilegesEntryAuth"}' "https://ipOfOpInstanceServer/get-password"
		```


## METHODS (pros/cons):

With method 1, the credentials are captured when your container is comming up. So if the auth token does not have the privileges, the password is not retrieved. If you update the privileges.json, you will need to restart your container to re-init the credentials now that it has access.  Similarly, if you change the password in your 1password, the application will continue to use the old password until your restart your container.

With method 2, the password is retrieved "on-the-fly".  If you update your privileges.json file, your application will have the access immediately.  If you update a password in your 1password vault, the application will be able to retrieve the new password when it makes the curl request.
