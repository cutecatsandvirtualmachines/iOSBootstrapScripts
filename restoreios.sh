#!/bin/bash

idevicerestore -P -d --erase --restore-mode -i 0x1122334455667788 $ipswname --debug -T ~/root_ticket.der -y
