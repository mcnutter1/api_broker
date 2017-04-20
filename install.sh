yes | cp -rf src/* /
ln -s /opt/api_interface/api_interface /usr/bin/api_interface
sudo update-rc.d api_interface defaults
sudo update-rc.d api_interface  enable
