#!/bin/bash

cd app/
sudo chown -R 1000:1000 /home/vagrant/.npm/
sudo npm install
npm start
