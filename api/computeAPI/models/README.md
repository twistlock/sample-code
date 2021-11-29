= Scripts to set runtime models to different states =

== Prerequisites: 

1. python installed
2. jq installed

== Instructions to change all models to active

1.  run 'python getModels.py <image name>'
       if you leave off image name, this will find and save all runtime model ID's
2. run changeState manualLearning modelIDs.txt
3. run changeState manualActive modelIDs.txt

 
