#!/usr/bin/bash

upower -i $(upower -e | grep battery) | grep -E "percentage|state"
