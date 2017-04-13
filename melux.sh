#!/bin/bash

VERSION=1.0;
#  **********************************
# * 		melux 1.0	     *
# *  ubuntu iso customization script *
# *			  	     *
# *   Copyright: Dimitris Kalamaras  *
# *   Free to use under GPL3 licence *
# *     http://dimitris.apeiro.gr    *
#  **********************************




loop='./loop/';
work='./work/';
squash='./work/casper/filesystem.squashfs';  # DON'T CHANGE THIS!
new_squash_dir='./squashdir/';


# STEP 1: SPECIFY PACKAGES TO ADD HERE! (hint: use synaptic to find more packages and apt-cache rdepends to see what depends on them)

build_packages='build-essential';
desktop_packages='vlc ttf-liberation ktorrent inkscape scummvm njam'; 
mce_packages='elisa';

# WARNING: dont try to install....
#	wine or squid; those depend on samba winbind which needs /proc...
#       virtualbox-ose;  it needs kernel module so...
#	bootchart; depends on bootchart-java, so dont install it...
#	flashplugin-nonfree; it cannot be redistributed.

multimedia_packages='gstreamer0.10-plugins-ugly gstreamer0.10-plugins-ugly-multiverse  gstreamer0.10-plugins-bad gstreamer0.10-plugins-bad-multiverse gstreamer0.10-ffmpeg libavcodec-unstripped-52 gstreamer0.10-pitfdll libdvdread4 ffmpeg ffmpeg2theora';
math_packages='octave3.0 kig ygraph qtoctave wxmaxima lybniz';
devel_packages='libqt4-assistant libqt4-gui qt4-doc-html qt4-qtconfig qt4-demos libqt4-webkit libqt4-dev qt4-designer qdevelop vim subversion bzr mc';
greek_packages='language-support-el language-pack-el myspell-dictionary-el language-pack-gnome-el';
kde_packages='kubuntu-desktop';
download_packages='virtualbox-ose wine squid bootchart flashplugin-nonfree unrar';



#
# THAT'S ALL. JUST RELAX WHILE WE ARE MAKING YOUR CUSTOM UBUNTU ISO!!! 
#



red='\E[1;31m';
green='\E[1;32m';
black='\E[1;37;38m';
white='e[1;37m';
normal='tput sgr0';


choose_packages() {
	echo    -e $black'Press 1-9 to choose packages or press 0 to continue...';$normal;
	echo -n -e $red'1.'; echo -e $black ' Build        ...';$normal;
	echo -n -e $red'2.'; echo -e $black ' Desktop      ...';$normal;
	echo -n -e $red'3.'; echo -e $black ' Development  ...';$normal;
	echo -n -e $red'4.'; echo -e $black ' Multimedia   ...';$normal;
	echo -n -e $red'5.'; echo -e $black ' Mathematics  ...';$normal;
        echo -n -e $red'6.'; echo -e $black ' Media center ...';$normal;
	echo -n -e $red'7.'; echo -e $black ' KDE desktop  ...';$normal;
        echo -n -e $red'9.'; echo -e $black ' All          ...';$normal;
	echo -n -e $red'0.'; echo -e $black ' DONE!        ...';$normal;
	echo -n -e $red'> '; $normal;
	read answer;
	return $answer;
}




echo    -e $red '  **********************************';
echo -n -e $red ' * ';$normal;echo -n "           melux $VERSION            ";echo -e $red '*';
echo -n -e $red ' * ';$normal;echo -n 'ubuntu iso customization script ';echo -e $red '*';
echo -n -e $red ' * ';$normal;echo -n ' copyright: Dimitris Kalamaras  ';echo -e $red '*';
echo -n -e $red ' * ';$normal;echo -n ' free to use under GPL3 licence ';echo -e $red '*';
echo -n -e $red ' * ';$normal;echo -n '   http://dimitris.apeiro.gr    ';echo -e $red '*';
echo    -e $red '  **********************************';



echo -n -e $black'checking mksquashfs   ...'; $normal;
if [ -f /usr/bin/mksquashfs ]; then
	echo -e $green 'OK'; $normal;
	
else
	echo -e $red 'mksquashfs not found! Installing package...';
	sudo apt-get install squashfs-tools
fi

echo -n -e $black'unmounting old mounts ...'; $normal;
mounted=`mount | grep $new_squash_dir | awk '{ print $3 }' `;
for i in $mounted; do
        sudo umount $i;
done
echo -e $green 'OK'; $normal;

echo    -e $black'enter new base dir    ...' $red 'this is where the original iso should be!'; $normal; 
read dir;


echo    -e $black'entering base dir     ...' $dir; $normal;
cd $dir;

echo    -e $black'enter ubuntu release  ...' $red 'i.e. jaunty  (sould be the same version you run now!)'; $normal;
read release;

echo    -e $black'enter new iso name    ...' $red 'i.e. newubuntu-i386 (without .iso)'; $normal;
read newubuntu;


echo -n -e $black'preparing sources.list...'; $normal;

echo "deb http://security.ubuntu.com/ubuntu $release-security main restricted" > ./sources.list
echo "deb http://archive.ubuntu.com/ubuntu $release-updates main restricted" >> ./sources.list;
echo "deb http://archive.ubuntu.com/ubuntu/ $release  main restricted universe multiverse" >> ./sources.list
sleep 1;
echo -e $green 'OK'; $normal;



echo -n -e $black'checking loop dir     ...'; $normal;
sleep 1;
if [ -d $loop ]; then
	echo -e $green 'OK'; $normal;
	sudo umount $loop &> /dev/null;
else
	echo -e $red 'creating dir'; $normal;
	mkdir $loop;
fi



orig=`ls *.iso | grep ubuntu-`;
echo -n -e $black'mounting original iso ...'; 
sleep 1;
if [ -f $orig ]; then
	sudo mount -o loop $orig $loop
        echo -e $green 'OK';
else
        echo -e $red 'iso not found!';
	echo -e $black'bye!';
	exit;
fi



echo -n -e $black'checking working dir  ...';
sleep 1;
if [ -d $work ]; then
        #sudo rm -rf $work;
        size=`sudo du -h -s  $work  | awk '{print $1}'`;
        echo -e $green 'OK. Warning: work dir exists. Contents: ' $size;
else
        echo -e $red 'creating work dir';
        mkdir $work;
fi


echo -n -e $black'copying original iso  ...';
#sleep 1;
sudo rsync -avx --progress $loop $work &> /dev/null;
echo -e $green 'OK';

echo -n -e $black'unmount original iso  ...';
sleep 1;
sudo umount $loop;
echo -e $green 'OK';



echo -n -e $black'mounting squash file  ...';
sleep 1;
if [ -f $squash ]; then
        sudo mount -t squashfs -o loop  $squash $loop &> /dev/null;
	echo -e $green 'OK';
else
        echo -e $red 'cannot find filesystem.squashfs!';
        echo -e $black'bye!';
        exit;
fi



echo -n -e $black'checking new_squashdir...';
sleep 1;
if [ -d $new_squash_dir ]; then
       #sudo rm -rf $new_squash_dir;
	size=`sudo du -h -s  $new_squash_dir  | awk '{print $1}'`;
	echo -e $green 'OK. Warning: $new_squash_dir exists. Contents: ' $size;
else
        echo -e $red 'creating new squash dir';
        mkdir $new_squash_dir;
fi



echo -n -e $black'copying orig squashfs ...';
#sleep 1;
sudo rsync -av --progress $loop $new_squash_dir &> /dev/null;
size=`sudo du -h -s  $new_squash_dir  | awk '{print $1}'`;
echo -e $green 'OK. Copied over: ' $size ;

echo -n -e $black'unmount orig squashfs ...';
sleep 1;
sudo umount $loop;
echo -e $green 'OK';



echo -n -e $black'mounting dev > squash ...';
if [ -d $new_squash_dir ]; then
        sudo mount --bind /dev $new_squash_dir/dev &> /dev/null;
      	sudo mount --bind /var/run/dbus/ $new_squash_dir/var/run/dbus/ ;
	echo -e $green 'OK';
else
        echo -e $red 'cannot bind /dev!';
        echo -e $black'bye!';
        exit;
fi



echo -n -e $black'copying resolv.conf   ...';
if [ -f $new_squash_dir/etc/resolv.conf.orig ]; then
        sudo cp /etc/resolv.conf $new_squash_dir/etc/
else
	if [ -f $new_squash_dir/etc/resolv.conf ]; then
		sudo mv $new_squash_dir/etc/resolv.conf $new_squash_dir/etc/resolv.conf.orig
	fi
        sudo cp /etc/resolv.conf $new_squash_dir/etc/ 
	
fi

echo -e $green 'OK';

dns=`sudo cat $new_squash_dir/etc/resolv.conf | grep name | awk '{ print $2 }'`;
echo    -e $black'using this dns server ...' $green $dns;



echo    -e $black'chrooting: list chroot...'; $normal;
echo " ";
sudo chroot $new_squash_dir/ ls


echo " ";
echo -n -e $black'adding new repos      ...';
if [ -f $new_squash_dir/etc/apt/sources.list.orig ]; then
	sudo mv ./sources.list $new_squash_dir/etc/apt/
	echo -e $green 'OK';$normal;
else
	sudo cp $new_squash_dir/etc/apt/sources.list $new_squash_dir/etc/apt/sources.list.orig
	sudo mv ./sources.list $new_squash_dir/etc/apt/
	echo -e $green 'COPIED';$normal;
fi


echo " ";
echo    -e $black'chrooting: update     ...'; $normal;
sudo chroot $new_squash_dir/ apt-get update


echo " ";
echo    -e $black'chrooting: removing not needed language packages    ...'; $normal;
sudo chroot $new_squash_dir/   apt-get purge `dpkg -l language-pack-* | grep -v language-pack-el | grep -v language-pack-en | grep -v language-pack-gnome-en | grep -v language-pack-gnome-el | grep -v kde | grep -v Status | grep -v "Name" | grep -v "\Ό\ν\ο\μ\α" | awk '{print $2}'`


echo " ";
echo    -e $black'chrooting: installing essential/restricted packages ...';$normal;
answer=1;
while [  $answer -gt '0' ]; do
	choose_packages;
	answer=$?
	case $answer in
	1)
	sudo chroot $new_squash_dir/ apt-get install $build_packages;
	  ;;
	2)
	sudo chroot $new_squash_dir/ apt-get install $desktop_packages;
	  ;;
	3)
	sudo chroot $new_squash_dir/ apt-get install $devel_packages;
	  ;;
	4)
	sudo chroot $new_squash_dir/ apt-get install $multimedia_packages;
	  ;;
	5)
	sudo chroot $new_squash_dir/ apt-get install $math_packages;
	  ;;
        6)
        sudo chroot $new_squash_dir/ apt-get install $mce_packages;
          ;;
	7)
	sudo chroot $new_squash_dir/ apt-get install $kde_packages;
	;;
	8)
	sudo chroot $new_squash_dir/ apt-get install $kde_packages $desktop_packages $multimedia_packages $devel_packages;
	;;
        9)
        sudo chroot $new_squash_dir/ apt-get install $build_packages $desktop_packages $multimedia_packages $devel_packages $math_packages $mce_packages;
          ;;
	esac	
done


#sudo chroot $new_squash_dir/ apt-get install $build_packages $desktop_packages $multimedia_packages $devel_packages $math_packages;


echo " ";
echo    -e $black'chrooting: adding greek language packages          ...';$normal;
sudo chroot $new_squash_dir/ apt-get install $greek_packages;


echo " ";
echo -n -e $black'cleaning squash dir   ...';$normal;
sudo chroot $new_squash_dir/ apt-get clean
echo -e $green 'OK';$normal;


echo " ";
echo -n -e $black'removing temp files   ...';$normal;
sudo chroot $new_squash_dir/ mv /etc/resolv.conf.orig /etc/resolv.conf
sudo chroot $new_squash_dir/ mv /etc/apt/sources.list.orig /etc/apt/sources.list


if [ -f $new_squash_dir/etc/apt/sources.list.orig ]; then
	echo -e $red 'FAIL!';$normal;
else
	echo -e $green 'OK';$normal;	
fi

echo " ";
echo -n -e $black'updating squash file  ...';$normal;
sudo chroot $new_squash_dir dpkg-query -W --showformat='${Package} ${Version}\n' | grep -v deinstall > filesystem.manifest
sudo mv ./filesystem.manifest $work/casper/
echo -e $green 'OK';$normal;


echo " ";
echo -n -e $black'creating sed script   ...';$normal;
echo "/casper/d" > ./sedscript 
echo "/libdebian-installer4/d" >> ./sedscript
echo "/os-prober/d" >> ./sedscript
echo "/ubiquity/d" >> ./sedscript
echo "/ubuntu-live/d" >> ./sedscript
echo "/user-setup/d" >> ./sedscript
echo -e $green 'OK';$normal;

echo -n -e $black'executing the script  ...';$normal
sudo sed -f ./sedscript < $work/casper/filesystem.manifest > filesystem.manifest-desktop
sudo mv filesystem.manifest-desktop $work/casper/
echo -e $green 'OK';$normal;


echo " ";
echo -n -e $black'making new squashfs   ...';$normal;
sudo mksquashfs $new_squash_dir/ $work/casper/filesystem.squashfs -noappend
echo -e $green 'OK';$normal;


echo " ";
echo -n -e $black'entering working dir  ...';$normal;
cd $work;
echo -e $green 'OK';$normal;

echo " ";
echo -n -e $black'updating md5sums file ...';$normal;
sudo find . -type f -print0 | xargs -0 md5sum > md5sum.txt
echo -e $green 'OK';$normal


echo " ";
echo -n -e $black'creating NEW ISO!!!   ...';$normal;
sudo mkisofs -r -v -V "UbuntuNew" -cache-inodes -J -l  -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -publisher "Dimitris Kalamaras" -p "dimitris.kalamaras@yourmail.com"  -o ../$newubuntu.iso .

cd ..

if [ -f $newubuntu.iso ]; then
        echo -e $green 'OK';$normal;
else
	echo -e $red 'Sorry. I failed to make the iso....';$normal;
fi

# make all sane!
tput sgr0
echo ' ' ;
echo -e $black'bye!';$normal;

