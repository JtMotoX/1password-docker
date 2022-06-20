<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>sample-app</title>
</head>

<body>
	<div>
		Method 1:<br>
		<?= getenv("HEY"); ?>
	</div>
	<div>
		Method 2:<br>
		<?
		$url = getenv("OP_ENDPOINT")."/get-password";
		$ch = curl_init($url);
		$payload = json_encode(array(
			"vault_name" => getenv("OP_VAULT"),
			"item_title" => getenv("OP_MY_ITEM_NAME"),
			"auth" => getenv("OP_AUTH")
		));
		curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		$result = curl_exec($ch);
		curl_close($ch);
		// echo "$result";
		$json = json_decode($result, true);
		echo $json['password'];
		?>
	</div>
</body>

</html>