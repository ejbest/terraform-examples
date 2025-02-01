#!/bin/bash

# Set up SSH authorized keys for the root user
mkdir -p /root/.ssh
echo "${SSH_PUBLIC_KEY}" > /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
