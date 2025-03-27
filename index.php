<?php
  include_once("./config.php");

  $clearvote = $_GET["clearvote"] ?? "";

  if (isset($clearvote) && $clearvote == true) {
    mysqli_multi_query($connection, "truncate table haaletus; truncate table logi; truncate table tulemused;");
    Header("Location: index.php");
    exit();
  }

  $result = mysqli_query($connection, "select * from tulemused order by haaletuse_id desc");

  $poolt = mysqli_query($connection, "select * from haaletus where otsus = 'poolt'");
  $poolt_arvestatud = mysqli_query($connection, "select * from haaletus where otsus = 'poolt' and arvestatud = 1");

  $vastu = mysqli_query($connection, "select * from haaletus where otsus = 'vastu'");
  $vastu_arvestatud = mysqli_query($connection, "select * from haaletus where otsus = 'vastu' and arvestatud = 1");

  $ajad = mysqli_query($connection, "select h_alguse_aeg as algus, h_lopu_aeg as lopp from tulemused");
  $ajad_array = mysqli_fetch_array($ajad);
  $algus_kuupaev = "";
  $lopp_kuupaev = "";
  $algus_time = -1;
  $lopp_time = -1;
  $algus_string = "Hääletus pole veel alanud.";
  $lopp_string = "";

  if ($ajad && mysqli_num_rows($ajad) > 0 ) {
    $algus_kuupaev = new DateTime($ajad_array["algus"], new DateTimeZone("Europe/Tallinn"));
    $lopp_kuupaev = new DateTime($ajad_array["lopp"], new DateTimeZone("Europe/Tallinn"));

    $algus_time = $algus_kuupaev -> format(DateTime::ATOM);
    $lopp_time = $lopp_kuupaev -> format(DateTime::ATOM);

    $algus_string = "Algus: " . $ajad_array["algus"];
    $lopp_string = "Lõpp: " . $ajad_array["lopp"];
  }
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="styles/styles.css">
  <link rel="stylesheet" href="styles/header.css">
  <title>Hääletamise rakendus</title>
</head>
<body>
  <?php include_once("./header.php") ?>
  <div class="vote-container">
    <div class='vote-item'>
      <span class='vote-title'>Hääletus</span>
      <div class='vote-result'>
        <span><?php echo $algus_string ?></span>
        <span><?php echo $lopp_string ?></span>
        <span id="timeleft"></span>
      </div>
      <div class='vote-result'>
        <span>Poolt: <?php echo mysqli_num_rows($poolt_arvestatud) ?> (<?php echo mysqli_num_rows($poolt) ?>)</span>
        <span>Vastu: <?php echo mysqli_num_rows($vastu_arvestatud) ?> (<?php echo mysqli_num_rows($vastu) ?>)</span>
      </div>
      <div class="vote-controls">
        <a href="./vote.php" class="button" onclick="">Hääleta või muuda</a>
      </div>
    </div>
  </div>
  <script>
    // wtf ever
    const timeleftElement = document.getElementById("timeleft")
    const startTimeStamp = "<?php echo $algus_time ?>"
    const endTimeStamp = "<?php echo $lopp_time ?>"
    const startTime = new Date(startTimeStamp);
    const endTime = new Date(endTimeStamp)
    const curTime = new Date()

    let timeleft = Math.floor((endTime - curTime) / 1000)

    const tickTimer = () => {
      if (!isNaN(timeleft) && timeleft > 0) {
        timeleftElement.innerHTML = `Aega jäänud: ${timeleft}`
        timeleft -= 1
        setTimeout(tickTimer, 1000);
      }
      else {
        timeleftElement.innerHTML = "AEG LÄBI!"
      }
    }

    if (startTimeStamp !== "-1" && endTimeStamp !== "-1") {
      tickTimer()
    }
  </script>
</body>
</html>