#!/bin/bash

cd iosemu

sshpass -p '132435' scp -o StrictHostKeyChecking=no $(pwd)/root_ticket.der username@10.0.2.15:~
sshpass -p '132435' scp -o StrictHostKeyChecking=no $ipswname username@10.0.2.15:~