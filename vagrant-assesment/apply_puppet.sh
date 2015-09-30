#!/bin/bash

puppet apply --modulepath=puppet/modules puppet/manifests/default.pp
