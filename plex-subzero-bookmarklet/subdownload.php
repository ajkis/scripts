/*
To be used with bookmarklet.html
Change the XXX part in like 29 to match your plex domain/ip )
Change YYY with your plex token
*/

<html>
<head>
  <title>Subtitles download</title>
  </head>
<body style="background-color: #1F1F1F;";>
<br>
<div><p style="color:white;text-align:center;font-size:18px";><i>PLEX FORCE SUBTITLE DOWNLOAD</div>
</body>
</html>

<?php

function is_hex($hexValue){
	if($hexValue == dechex(hexdec($hexValue)))
        return true;
    return false;
}

$id=$_GET["id"];
$u=$_GET["u"];
if (is_hex($id)) {
	// set up the curl resource
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, "http://XXX/video/subzero/item/".$id."/force?X-Plex-Token=YYY");
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
	$output = curl_exec($ch);
	echo($output) . PHP_EOL;
	curl_close($ch);

	header("Location: " . $u);
	//echo("<html><body>".$u."</body></html>");
} else {
	//echo("<html><body>Dude, you clicked it on wrong page!</body></html>");
	header("Location: " . $u);
}
?>
