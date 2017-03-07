 #!/bin/bash
 # SET THE CORRECT PATH 
 for file in /path to root folder with movies/*.mkv
 do
     folder=$(basename "$file" .mkv)
     mkdir "$folder" && mv "$file" "$folder"
 done
 exit
