#!/bin/sh

# REQUIRED FOR METHOD 1
curl -sS -o /tmp/1password-vars.sh "https://raw.githubusercontent.com/JtMotoX/1password-docker/main/1password/op-vars.sh"
chmod 755 /tmp/1password-vars.sh
. /tmp/1password-vars.sh || exit 1
rm -f /tmp/1password-vars.sh

# THE ENTRYPOINT + CMD OF THE ORIGINAL IMAGE
docker-php-entrypoint apache2-foreground
