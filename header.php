<?php
  include_once("./config.php");

  if (isset($_GET["action"]) && $_GET["action"] === "new_vote") {
    header("Location: index.php");
  };
?>

<header>
  <a id="header-title" href="./index.php">Hääletamise rakendus</a>
  <ul>
    <li><a href="index.php?clearvote=1">Uus hääletus</a></li>
  </ul>
</header>