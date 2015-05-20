VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provision "shell" do |s|
    s.inline = <<EOS
apt-get update
apt-get install git -y
apt-get install build-essential -y

curl -sSL https://rvm.io/mpapis.asc | sudo gpg --import -

curl -sSL https://get.rvm.io | bash -s stable
source /usr/local/rvm/scripts/rvm

rvm use --install 2.1.5
gem install bundler
EOS

  end
end

