╭─  kali    …/192.168.135.111/nmap  
╰ cat connect.php                               0.02s    05:20  3.91G  
───────┬────────────────────────────────────────────────────────────────────────
       │ File: connect.php
───────┼────────────────────────────────────────────────────────────────────────
   1   │ <?php   
   2   │    
   3   │ $conn = new mysqli("localhost, "test", "removeaftertests", "mysql");   
   4   │    
   5   │ if($conn->connect_error) {   
   6   │     die("ERROR: Unable to connect: " . $conn->connect_error);   
   7   │ }   
   8   │   
   9   │ echo "Connected to the database.<br>";   
  10   │ $result = $conn->query("SELECT user FROM mysql");   
  11   │ echo "Number of rows: $result->num_rows";   
  12   │ $result->close();  
  13   │ $conn->close();   
  14   │    
  15   │ ?>   
───────┴────────────────────────────────────────────────────────────────────────

