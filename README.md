# Modeling Commons

## Optional Packages

In getting the Modeling Commons working in a VM, I installed a ton of libraries, using the following command:

```sh
sudo apt install -y accountsservice acpid adduser apache2 apache2-dev apparmor apport apport-symptoms apt apt-transport-https apt-utils aptitude at atop base-files base-passwd bash bash-completion bc bind9-host bsd-mailx bsdmainutils bsdutils build-essential busybox-initramfs busybox-static byobu bzip2 ca-certificates command-not-found console-setup coreutils cpio cron cron-apt curl dash dbus debconf debconf-i18n debianutils dh-python diffutils dmidecode dmsetup dnsutils dosfstools dovecot-core dovecot-imapd dovecot-pop3d dpkg e2fslibs e2fsprogs ed eject emacs ethtool fail2ban file findutils finger friendly-recovery ftp fuse gawk geoip-database gettext-base gir1.2-glib-2.0 git gnupg gpgv graphviz grep groff-base grub-common grub-pc gzip hdparm hostname htop ifupdown imagemagick info init-system-helpers initramfs-tools initramfs-tools-bin install-info installation-report iotop iproute2 iptables iputils-ping iputils-tracepath irqbalance isc-dhcp-client isc-dhcp-common iso-codes kbd keyboard-configuration klibc-utils kmod krb5-config krb5-locales krb5-user landscape-client landscape-common language-pack-en language-selector-common less libaccountsservice0 libacl1 libapparmor-perl libapparmor1 libapr1-dev libaprutil1-dev libarchive-extract-perl libasn1-8-heimdal libassuan0 libattr1 libaudit-common libaudit1 libblkid1 libbsd0 libbz2-1.0 libc-bin libc6 libcap-ng0 libcap2 libcap2-bin libcomerr2 libcurl3-gnutls libcurl4-openssl-dev libdb-dev libdb5.3 libdbus-1-3 libdbus-glib-1-2 libdebconfclient0 libdevmapper1.02.1 libdrm2 libedit2 libelf1 libestr0 libexpat1 libffi-dev libfribidi0 libfuse2 libgc1c2 libgcc1 libgck-1-0 libgcr-base-3-1 libgdbm-dev libgeoip1 libgirepository-1.0-1 libglib2.0-0 libglib2.0-data libgnutls-openssl27 libgpg-error0 libgpgme11 libgpm2 libgraphicsmagick++1-dev libgraphicsmagick1-dev libgssapi-krb5-2 libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal libheimntlm0-heimdal libhx509-5-heimdal libidn11 libiw30 libk5crypto3 libkeyutils1 libklibc libkmod2 libkrb5-26-heimdal libkrb5-3 libkrb5support0 libldap-2.4-2 liblocale-gettext-perl liblockfile-bin liblockfile1 liblog-message-simple-perl liblzma5 libmagic1 libmagick++-dev libmagickcore-dev libmagickwand-dev libmodule-pluggable-perl libmount1 libmpdec2 libncurses5 libncursesw5 libnewt0.52 libnfnetlink0 libnl-3-200 libnl-genl-3-200 libnuma1 libp11-kit0 libpam-cap libpam-krb5 libpam-modules libpam-modules-bin libpam-runtime libpam-systemd libpam0g libpcap0.8 libpci3 libpcre3 libpcsclite1 libpipeline1 libpod-latex-perl libpolkit-agent-1-0 libpolkit-gobject-1-0 libpopt0 libpython2.7 libpython2.7-minimal libpython2.7-stdlib libpython3-stdlib libreadline-dev libreadline5 libroken18-heimdal libsasl2-2 libsasl2-modules libsasl2-modules-db libselinux1 libsemanage-common libsemanage1 libsepol1 libsigsegv2 libslang2 libsqlite3-0 libss2 libssl-dev libstdc++6 libtasn1-6 libterm-ui-perl libtext-charwidth-perl libtext-iconv-perl libtext-soundex-perl libtext-wrapi18n-perl libtinfo5 libtokyocabinet9 libudev1 libusb-0.1-4 libusb-1.0-0 libustr-1.0-1 libuuid1 libwind0-heimdal libwrap0 libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxext6 libxml2 libxmuu1 links linux-generic linux-headers-generic linux-headers-virtual locales lockfile-progs login logrotate lsb-base lsb-release lshw lsof ltrace lvm2 makedev man-db manpages mawk memtest86+ mime-support mlocate mosh mount mtr-tiny mutt nano ncftp ncurses-base ncurses-bin ncurses-term net-tools netbase netcat-openbsd nmon ntfs-3g ntp ntpdate openssh-client openssh-server openssh-sftp-server openssl parted passwd patch pciutils perl perl-base plymouth plymouth-theme-ubuntu-text policykit-1 popularity-contest postfix postgresql powermgmt-base ppp pppconfig pppoeconf procmail procps psmisc python-apt python-apt-common python-chardet python-debian python-gdbm python-is-python2 python-openssl python-pam python-pkg-resources python-six python-zope.interface python2.7 python2.7-minimal python3 python3-apport python3-apt python3-commandnotfound python3-dbus python3-distupgrade python3-gdbm python3-gi python3-minimal python3-newt python3-problem-report python3-pycurl python3-software-properties python3-update-manager readline-common resolvconf rsync rsyslog ruby ruby-rmagick run-one screen sed sensible-utils sgml-base shared-mime-info shorewall smartmontools snapd software-properties-common ssh-import-id ssl-cert strace sudo systemd-sysv sysvinit-utils tar tasksel tcpd tcpdump telnet time tmux tzdata ubuntu-advantage-tools ubuntu-keyring ubuntu-minimal ubuntu-release-upgrader-core ubuntu-standard ucf udev ufw unattended-upgrades unzip update-manager update-manager-core update-notifier-common usbutils util-linux uuid-runtime vim vim-common vim-runtime vim-tiny w3m wget whiptail wireless-tools wpasupplicant xauth xkb-data xml-core xz-utils zabbix-agent zip zlib1g zsh
```

However, I don't recommend installing them proactively.  Probably only a small subset of them was necessary.  Use that list as a reference, but try to figure out the minimal list of things that need to be installed.

## Installation

Instructions here will assume that you're on Ubuntu.  I (Jason) did not have good luck with trying to make this thing install on Ubuntu 24.04, so I used 20.04, where I found success.  Note that you will probably need to install some additional libraries or programs, if going by these instructions, since they were cobbled together after the fact.  You can update this document with anything that was missed.

First thing we have have to do, after getting our OS/VM set up is get some libraries set up.  To do that, run this in the terminal:

```sh
sudo apt update
sudo apt install -y git libpq-dev ruby-dev
```

Next, we need the right version of Ruby.  The easiest way to do that is to install it through RVM, which (for Ubuntu) comes from [here](github.com/rvm/ubuntu_rvm).

After you've followed those instructions (including logging out and back in, sadly, in order for your group membership to update), you're ready to install the version of Ruby that we need.  Do that with the command `rvm install "ruby-2.2.0"`.

Next, we need the right version of the Ruby bundler, as installed by `gem install bundler:1.17.3`.

Maybe `bundler` ends up in the right place.  Maybe not.  You can find it at `/usr/share/rvm/rubies/ruby-2.2.0/lib/ruby/gems/2.2.0/gems/bundler-1.17.3/exe/bundle`, and that's the executable that we'll be referring to with `bundle`, going forward.

Also, if you haven't already, download this repo with Git and `cd` into it.

Next, we need to get all of the Ruby libraries installed.  You can run `bundle install` to achieve that.

Finally, while we wait for the libraries to install, we should get the database set up.  Run `sudo -u postgres psql` to get into the Postgres SQL console.  Then, run:

```sql
CREATE USER nlcommons WITH PASSWORD 'nlcommons';
CREATE DATABASE nlcommons_development;
```

After that, run `sudo -u postgres psql -d nlcommons_development < ./db/schema.sql` to get the tables set up correctly.  Theoretically, `rake` could have been used for this instead, but my experience was that several of the migration scripts referred to things that were never actually in the database, to begin with, and, thus, would not properly run to completion.

It's all well and good to have the schema imported, but that doesn't seem to cover everything.  There seems to be some static data that needs to be read from the database in order for the application to run correctly.  That data must be imported by running `sudo -u postgres psql nlcommons_development < ./db/base_data.sql`.

Once all of those commands have successfully completed, your database should be set.

However, my experience still resulted in some errors after launching the application, so I applied the following patch to the source to remove a relatively inconsequential feature (i.e. finding collaborators):

```patch
diff --git a/app/models/version.rb b/app/models/version.rb
index 3ab5c1e5..cfb28445 100644
--- a/app/models/version.rb
+++ b/app/models/version.rb
@@ -54,11 +54,11 @@ class Version < ActiveRecord::Base
       STDERR.puts "Looking for node '#{node_id}', but cannot find it"
     else

-      author_collaboration_id = CollaboratorType.find_by_name("Author").id
-      c =
-        Collaboration.find_or_create_by_node_id_and_person_id_and_collaborator_type_id(node.id,
-                                                                                       person.id,
-                                                                                       author_collaboration_id)
     end
   end
```

There are also some issues with embedding NetLogo Web from the `modelingcommons.netlogoweb.org` subdomain.  `netlogoweb.org` and `staging.netlogoweb.org` seem fine with plain HTTP, but `modelingcommons.netlogoweb.org` does not handle it well.  As a result, opening modelings from that subdomain is likely to get you errors, telling you that the model was loaded from an HTTP domain to the NLW site's HTTPS-based page, and that it's not okay with that.  To work around that while developing without the Modeling Commons server in HTTPS mode, you can change `app/views/browse/_browse_nlw_tab.html.erb` to use a different subdomain.

Once all of that is taken care of, you should be ready to launch the application.

## Running

Run `rails server`, and then find it in your browser at `localhost:3000`.

## Using

Your first order of business will probably be to create an account.  You can just put in any e-mail address.  It seems to open the would-be e-mail as a new tab in your browser (presumably, with no e-mail sent), so it doesn't need to be an address that you can actually receive e-mail at.
