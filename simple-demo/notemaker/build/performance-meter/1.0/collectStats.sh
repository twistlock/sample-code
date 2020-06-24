#!/bin/sh

# uses default period of 5 minutes unless something else is passed in
period=300
if [ ! -z $1 ]; then
   period=$1
fi

echo "Job started, gathering stats every $period seconds"
while [ forever ]
do
  echo "running mongotop and mongostat"  
  mongotop -h $MONGO_HOST -n 1
  mongostat -h $MONGO_HOST -n 1
  sleep $1
done

