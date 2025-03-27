<?php
  include_once("./config.php");

  if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $name = htmlspecialchars($_POST["name"]);
    $choice = htmlspecialchars($_POST["choice"]);

    $statement = $connection -> prepare("select count(*) from haaletus where nimi = ?");
    $statement -> bind_param("s", $name);
    $statement -> execute();
    $statement -> bind_result($count);
    $statement -> fetch();
    $statement -> close();

    if ($count > 0) {
      $statement = $connection -> prepare("update haaletus set otsus = ?, aeg = now() where nimi = ?");
      $statement -> bind_param("ss", $choice, $name);
    } else {
      $statement = $connection -> prepare("insert into haaletus (nimi, aeg, otsus) values (?, now(), ?)");
      $statement -> bind_param("ss", $name, $choice);
    }

    $statement -> execute();
    $statement -> close();

    header("Location: ./index.php");
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
      <form action="vote.php" method="POST" name="vote-form" class="vote-form">
        <div>
          <div>
            <label for="name">Nimi</label>
            <input type="text" name="name" id="name" placeholder="Sisesta oma nimi.." required>
          </div>
          <div>
            <select name="choice" id="option">
              <option value="poolt">Poolt</option>
              <option value="vastu">Vastu</option>
            </select>
          </div>
        </div>
        <input type="submit" class="button green" value="Saada">
      </form>
    </div>
  </div>
</body>
</html>