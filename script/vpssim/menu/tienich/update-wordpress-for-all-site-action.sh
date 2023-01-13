#!/bin/bash
if [ ! -f /tmp/server_wp_all_update ] && [ -f /home/vpssim.conf ]; then
. /home/vpssim.conf
fi



# chuc nang cap nhat wordress cho toan bo website tren server
for_classic_editor="classic-editor.1.6.2"
for_yoast_seo="wordpress-seo.19.14"
for_elementor="elementor.3.10.0"


echoY() {
    echo -e "\033[38;5;148m${1}\033[39m"
}
echoG() {
    echo -e "\033[38;5;71m${1}\033[39m"
}
echoR()
{
    echo -e "\033[38;5;203m${1}\033[39m"
}


# dọn dẹp file php trong thư mục wp-content, themes, plugins -> hạn chế tối đa mã độc ẩn chứa trong này
remove_php_in_wp_content(){
	if [ -d $1 ]; then
		rm -rf $1/*.php
		rm -rf $1/.htaccess
		echo "No money... No love..." > $1/index.php
	fi
}

remove_code_and_htaccess(){
	rm -rf $1/*
	rm -rf $1/.htaccess
}


#
cd ~
echo $(date) > /root/update-wordpress-for-all-site-log.txt

#
chmodUser=""

# cau hinh linh dong theo tung loai host
if [ -f /tmp/server_wp_all_update ]; then

. /tmp/server_wp_all_update

else

sleep 2
clear
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

#
DisableXmlrpc=0

echo -n "Enter dir for check and update (default /home): "
read DirSetup
if [ "$DirSetup" == "" ]; then
DirSetup="/home"
fi

if [ ! -d $DirSetup ]; then
echoR $DirSetup" not exist..."
exit
fi

echo -n "Max dir for foreach (maximum 10, default 3): "
read MaxCheck
if [ "$MaxCheck" == "" ]; then
MaxCheck=3
#elif [ "$MaxCheck" -gt 10 ]; then
#MaxCheck=10
fi

#if [ -f /etc/init.d/directadmin ] && [ ! "$DirSetup" == "/home" ]; then
if [ ! "$DirSetup" == "/home" ]; then
echo -n "chmod to user (default: auto detect): "
read chUser
chmodUser=$chUser
fi

fi

echoG "OK OK, check and update wordpres website in: "$DirSetup
echo "Max for: "$MaxCheck
echo "Disable Xmlrpc: "$DisableXmlrpc
echoY "Will begin after 2s..."
sleep 2
#exit



# install rsync if not exist
#current_os_version=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))

#rm -rf /root/test_rsync_for_wp_all_update
echo "Hello world..." > /tmp/test_rsync_for_wp_all_update
rsync -ah /tmp/test_rsync_for_wp_all_update /root

#
if [ ! -f /root/test_rsync_for_wp_all_update ]; then
echoY "Install rsync"
yum -y install rsync > /dev/null 2>&1
fi

rsync -ah /tmp/test_rsync_for_wp_all_update /root
if [ ! -f /root/test_rsync_for_wp_all_update ]; then
echoR "Rsync ERROR......."
exit
fi


# cap nhat cho cac file download
curTime=$(date +%d%H)
echo "curTime: "$curTime





# kiem tra va xoa cac file download cu
check_and_remmove_file_download(){

# $1 -> ten file can kiem tra -> thuong la .zip
# $2 -> thu muc con (neu co)

if [ ! "$2" == "" ]; then
mkdir -p /root/wp-all-update$2
cd /root/wp-all-update$2
else
cd /root/wp-all-update
fi

# kiem tra file size
if [ -f $1 ]; then
downloadSize=$(du -h $1 | awk 'NR==1 {print $1}')
if [ "$downloadSize" == "0" ]; then
echoR "Remove file... Filesize zero: "$1
rm -rf $1
fi
fi

# kiem tra xem file download wordress co chua
if [ -f $1 ]; then
#fileTime2=$(date -r $1 +%d)
fileTime2=$(date -r $1 +%d%H)
echo "fileTime2: "$fileTime2

# neu file duoc download lau roi -> cap nhat lai
if [ ! "$fileTime2" == "$curTime" ]; then

# xoa ca thu muc neu la file wp.zip
if [ "$1" == "wp.zip" ]; then
remove_code_and_htaccess /root/wp-all-update
else
rm -rf $1
fi

else
echo "download exist: "$1
fi

fi

cd ~

}


#
mkdir -p /root/wp-all-update
#cd /root/wp-all-update

# timestamp
#timest=$(date +%s)
#echo "timest: "$timest


download_and_unzip_file(){

# $1 -> URL file download
# $2 -> ten file download xong con luu lai -> thuong la .zip
# $3 -> luu vao thu muc con (neu co)
# $4 -> xoa thu muc cu (neu co)

check_and_remmove_file_download $2 $3

if [ ! "$3" == "" ]; then
mkdir -p /root/wp-all-update$3
cd /root/wp-all-update$3
else
cd /root/wp-all-update
fi

if [ ! -f $2 ]; then
#echo "Download: "$1
echo "Start download: "$2
wget --no-check-certificate -q $1 -O $2 && chmod 755 $2

# khong download duoc -> thoat
if [ ! -f $2 ]; then
echoR "Download faild... File not exist: "$2
exit
fi

# kiem tra file size
downloadSize=$(du -h $2 | awk 'NR==1 {print $1}')
if [ "$downloadSize" == "0" ]; then
echoR "Download faild... Filesize zero: "$2
exit
fi

# thay doi thoi gian tao file cung voi server, de con kiem tra cap nhat lai code
echo "Set timestamp: "$2 ; touch -d "$(date)" $2

# giai nen
unzip -o $2 > /dev/null 2>&1
#else
#echo $2" exist"
fi

cd ~

}


# wordpres
download_and_unzip_file "https://wordpress.org/latest.zip" "wp.zip" ""
#download_and_unzip_file "https://echbay.com/daoloat/latest-vi.zip" "wp.zip" ""

file_optimize(){
f=$1
echo $f
# remove blank in first line
sed -i -e "s/^\s*//" $f
# remove blank in last line
sed -i -e "s/\s*$//" $f
# remove single comment line
sed -i -e '/^\s*\/\/.*$/d' $f
# remove blank in first line
sed -i -e "s/^\s*//" $f
# remove blank in last line
sed -i -e "s/\s*$//" $f
# remove blank line
sed -i -e "/^$/d" $f
sed -i -e '/^\s*$/d' $f
}

remove_single_comment_line(){
if [ -d $1 ]; then
	for d_optimize in $1/*
	do
		if [ -f $d_optimize ]; then
			#echo $d_optimize
			file_optimize $d_optimize
		fi
	done
fi
}

# echbaydotcom
download_and_unzip_file "https://github.com/itvn9online/echbaydotcom/archive/master.zip" "echbaydotcom.zip" ""
remove_single_comment_line "/root/wp-all-update/echbaydotcom-master/javascript"
remove_single_comment_line "/root/wp-all-update/echbaydotcom-master/css"

download_and_unzip_file "https://github.com/itvn9online/webgiareorg/archive/refs/heads/main.zip" "webgiareorg.zip" ""
remove_single_comment_line "/root/wp-all-update/webgiareorg-main/public/javascript"
remove_single_comment_line "/root/wp-all-update/webgiareorg-main/public/css"

download_and_unzip_file "https://github.com/itvn9online/echbaytwo/archive/master.zip" "echbaytwo.zip" ""
remove_single_comment_line "/root/wp-all-update/echbaytwo-master/javascript"
remove_single_comment_line "/root/wp-all-update/echbaytwo-master/css"
#exit

# download wordpress plugin hay dung nhat -> moi cap nhat chuc nang tim va download tu dong -> khong can phai thiet lap thu cong nua
download_wordpress_plugin(){
echoY "- - - - - - - - - Download new plugin: "$1" save to "$2
download_and_unzip_file "https://downloads.wordpress.org/plugin/"$1".zip" $2".zip" "/plugins"
}

re_download_plugin=""

rsync_wp_plugin(){

# $1 -> thu muc nguon
# $2 -> thu muc dich
# $3 -> lap lai hay khong, chi cho lap lai 1 lan

#echo $1
#echo $2

#download_wordpress_plugin $1

#echo $2/wp-content/plugins/$1

# plugin duoc tai ve roi thi thuc hien update
if [ -d "$2/wp-content/plugins/$1" ] && [ -d "/root/wp-all-update/plugins/$1" ]; then
	# xoa code cu di da
	echoY "cleanup - - - "$1
	remove_code_and_htaccess $2/wp-content/plugins/$1
	# sau do moi rsync
	echoG "rsync - - - "$1
	rsync -ah /root/wp-all-update/plugins/$1/* $2/wp-content/plugins/$1/ > /dev/null 2>&1
# chua duoc tai thi download ve
elif [ ! "$3" == "no" ]; then
	file404=/root/wp-all-update/plugins/---$1
	file500=/root/wp-all-update/plugins/-$1
	if [ ! -f $file404 ]; then
		# voi 1 so plugin, phai chi dinh ro ca phien ban can cap nhat
		download_version=$1
		if [ "$1" == "wordpress-seo" ]; then
			download_version=$for_yoast_seo
		elif [ "$1" == "classic-editor" ]; then
			download_version=$for_classic_editor
		elif [ "$1" == "elementor" ]; then
			download_version=$for_elementor
		fi

		# kiem tra xem plugin nay co tren wordpress khong
		ketnoi="https://downloads.wordpress.org/plugin/"$download_version".zip"
		ketnoi=$(curl -o /dev/null --silent --head --write-out '%{http_code}' $ketnoi)
		#ketnoi=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "https://downloads.wordpress.org/plugin/"$1".zip")
		#echo $ketnoi
		# neu co thi download ve de cap nhat cho website
		if [ "$ketnoi" == "200" ]; then
			download_wordpress_plugin $download_version $1
			sleep 1
			rsync_wp_plugin $1 $2 "no"
		elif [ "$ketnoi" == "404" ]; then
			# neu khong thi bao loi, thuong thi nhung plugin pro se khong co tren wordpress
			echoR "- - - - - - - - - WARNING... plugin not exist ("$ketnoi"): "$1
			# tao file de qua trinh kiem tra ket noi khong dien ra lien tuc
			echo $ketnoi > $file404
		else
			# neu khong thi bao loi, thuong thi nhung plugin pro se khong co tren wordpress
			echoY "- - - - - - - - - WARNING... plugin connect error "$ketnoi": "$1
			# tao file de qua trinh kiem tra ket noi khong dien ra lien tuc
			echo $ketnoi > $file500

			# download lai lan nua neu phat hien ra file khong ket noi duoc
			re_download_plugin="1"
		fi
	else
		echoR "- - - - - - - - - WARNING... plugin not exist (cache): "$1
	fi
else
	echoR "Re-download plugin faild: "$1
fi
}


# don dep code sau khi download
cd ~

# xoa thu muc wp-content
if [ -d /root/wp-all-update/wordpress/wp-content ]; then
remove_code_and_htaccess /root/wp-all-update/wordpress/wp-content
rm -rf /root/wp-all-update/wordpress/wp-content
fi

# khong ton tai wordpress -> thoat
if [ ! -d /root/wp-all-update/wordpress ]; then
echo "wordpress not exist"
exit
fi

# unzip echbaydotcom
if [ -d /root/wp-all-update/echbaydotcom-master ]; then
rm -rf /root/wp-all-update/echbaydotcom-master/.gitattributes
rm -rf /root/wp-all-update/echbaydotcom-master/.gitignore
# chinh lai thoi gian cap nhat
if [ -f /root/wp-all-update/echbaydotcom-master/readme.txt ]; then
	touch -d "$(date)" /root/wp-all-update/echbaydotcom-master/readme.txt
fi

# unzip code trong outsource cua echbaydotcom
cd ~
if [ -d /root/wp-all-update/echbaydotcom-master/outsource ]; then
cd /root/wp-all-update/echbaydotcom-master/outsource
for f_unzip in ./*.zip
do
echo $f_unzip
unzip -o $f_unzip > /dev/null 2>&1
done
cd ~
fi

fi
# END unzip echbaydotcom

# unzip webgiareorg
if [ -d /root/wp-all-update/webgiareorg-main ]; then
rm -rf /root/wp-all-update/webgiareorg-main/.gitattributes
rm -rf /root/wp-all-update/webgiareorg-main/.gitignore
# chinh lai thoi gian cap nhat
if [ -f /root/wp-all-update/webgiareorg-main/README.md ]; then
	touch -d "$(date)" /root/wp-all-update/webgiareorg-main/README.md
fi

# unzip code trong public thirdparty cua webgiareorg
cd ~
if [ -d /root/wp-all-update/webgiareorg-main/public/thirdparty ]; then
cd /root/wp-all-update/webgiareorg-main/public/thirdparty
for f_unzip in ./*.zip
do
echo $f_unzip
unzip -o $f_unzip > /dev/null 2>&1
done
cd ~
fi

fi
# END unzip webgiareorg

# unzip echbaytwo
if [ -d /root/wp-all-update/echbaytwo-master ]; then
rm -rf /root/wp-all-update/echbaytwo-master/.gitattributes
rm -rf /root/wp-all-update/echbaytwo-master/.gitignore
# chinh lai thoi gian cap nhat
if [ -f /root/wp-all-update/echbaytwo-master/index.php ]; then
	touch -d "$(date)" /root/wp-all-update/echbaytwo-master/index.php
fi

# unzip code trong outsource cua echbaytwo
cd ~
if [ -d /root/wp-all-update/echbaytwo-master/outsource ]; then
cd /root/wp-all-update/echbaytwo-master/outsource
for f_unzip in ./*.zip
do
echo $f_unzip
unzip -o $f_unzip > /dev/null 2>&1
done
cd ~
fi

fi
# END unzip echbaytwo

# phan quyen cho nginx quan ly
id -u nginx
if [ $? -eq 0 ]; then
	chown -R nginx:nginx /root/wp-all-update
fi



#exit
cd ~


# tim tat ca thu muc trong home
get_all_dir_in_dir(){
echo "--------------------------------------------------------"
echo "Pram 1: "$1
echo "Pram 2: "$2
echo "Pram 3: "$3
echo "Pram 4: "$4

# do sau toi da se kiem tra
if [ $2 -lt $3 ]; then
	for d in $1
	do
		# neu la thu muc thi kiem tra tiep
		if [ -d $d ]; then
			# neu la shortcut thi bo qua
			if [ -L $d ]; then
				echo $d"::It is a symlink..."
			else
				# tim it nhat 3 file va 3 thu muc bat buoc phai co cua wp
				if [ -f $d/wp-config.php ] && [ -f $d/wp-settings.php ] && [ -f $d/wp-blog-header.php ] && [ -d $d/wp-admin ] && [ -d $d/wp-content ] && [ -d $d/wp-includes ]; then
					# tim duoc website wp
					echoY $d"::It is a wordpress website"
					
					echo "Begin rsync... Please wait..."
					
					# wordpres core
					if [ -d /root/wp-all-update/wordpress ]; then
						#echoG "rsync - - - wordpress CORE..."
						# đồng bộ đồng thời xóa các file .php dư thừa -> chống virus
						rm -rf $d/wp-config.txt
						if [ -f $d/wp-config.php ]; then
							echoG "Backup wp-config..."
							mv -f $d/wp-config.php $d/wp-config.txt
						fi
						echoY "cleanup - - - PHP"
						rm -rf $d/*.php
						# rsync -avz
						echoG "rsync - - - PHP"
						rsync -ah --exclude="wp-config.php" --exclude="wp-admin/*" --exclude="wp-content/*" --exclude="wp-includes/*" /root/wp-all-update/wordpress/*.php $d/ > /dev/null 2>&1
						if [ -f $d/wp-config.txt ]; then
							echoG "Restore wp-config..."
							mv -f $d/wp-config.txt $d/wp-config.php
						fi
						# đồng bộ thư mục admin và includes
						if [ -d /root/wp-all-update/wordpress/wp-admin ]; then
							echoY "cleanup - - - wp-admin..."
							remove_code_and_htaccess $d/wp-admin
							rm -rf $d/wp-admin
							echoG "rsync - - - wp-admin..."
							rsync -ah /root/wp-all-update/wordpress/wp-admin $d/ > /dev/null 2>&1
							rsync -ah /root/wp-all-update/wordpress/wp-admin/* $d/wp-admin/ > /dev/null 2>&1
						fi
						if [ -d /root/wp-all-update/wordpress/wp-includes ]; then
							echoY "cleanup - - - wp-includes..."
							remove_code_and_htaccess $d/wp-includes
							rm -rf $d/wp-includes
							echoG "rsync - - - wp-includes..."
							rsync -ah /root/wp-all-update/wordpress/wp-includes $d/ > /dev/null 2>&1
							rsync -ah /root/wp-all-update/wordpress/wp-includes/* $d/wp-includes/ > /dev/null 2>&1
						fi
						echoY "cleanup - - - wp-content..."
						remove_php_in_wp_content $d/wp-content
						remove_php_in_wp_content $d/wp-content/plugins
						remove_php_in_wp_content $d/wp-content/themes
						# đồng bộ nốt các thư mục và file còn lại
						echoG "rsync - - - wp-index..."
						rsync -ah --exclude="wp-config.php" --exclude="wp-admin/*" --exclude="wp-content/*" --exclude="wp-includes/*" /root/wp-all-update/wordpress/* $d/ > /dev/null 2>&1
							
						#
						if [ "$DisableXmlrpc" -ne 0 ]; then
							# tắt xmlrpc để nhẹ web và tăng bảo mật
							echoG "Disable Xmlrpc..."
							echo "Hello world..." > $d/xmlrpc.php
						fi

					fi
					
					# echbaydotcom
					if [ -d /root/wp-all-update/echbaydotcom-master ] && [ -d "$d/wp-content/echbaydotcom" ]; then
						# nếu tồn tại cả thư mục webgiareorg -> cảnh báo ngay
						if [ -d "$d/wp-content/webgiareorg" ]; then
							echoR "echbaydotcom AND webgiareorg EXIST..."
							echo $d >> /root/update-wordpress-for-all-site-log.txt
							#sleep 30;
						fi
						
						echoY "cleanup - - - echbaydotcom..."
						remove_code_and_htaccess $d/wp-content/echbaydotcom
						echoG "rsync - - - echbaydotcom..."
						rsync -ah /root/wp-all-update/echbaydotcom-master/* $d/wp-content/echbaydotcom/ > /dev/null 2>&1
						#chown -R nginx:nginx $d/wp-content/echbaydotcom
						
						# copy file index-tmp.php de active WP_ACTIVE_WGR_SUPPER_CACHE luon va ngay
						if [ -f "$d/wp-content/echbaydotcom/index-tmp.php" ]; then
							echoG "active WP ACTIVE WGR SUPPER CACHE..."
							yes | cp -rf $d/wp-content/echbaydotcom/index-tmp.php $d/index.php
						fi

						# echbaytwo
						if [ -d /root/wp-all-update/echbaytwo-master ] && [ -d "$d/wp-content/themes/echbaytwo" ]; then
							echoY "cleanup - - - echbaytwo..."
							remove_code_and_htaccess $d/wp-content/themes/echbaytwo
							echoG "rsync - - - echbaytwo..."
							rsync -ah /root/wp-all-update/echbaytwo-master/* $d/wp-content/themes/echbaytwo/ > /dev/null 2>&1
							#chown -R nginx:nginx $d/wp-content/themes/echbaytwo
						fi
					# webgiareorg
					elif [ -d /root/wp-all-update/webgiareorg-main ] && [ -d "$d/wp-content/webgiareorg" ]; then
						# và không được có theme echbaytwo
						if [ -d "$d/wp-content/themes/echbaytwo" ]; then
							echoY "continue - - - echbaytwo..."
						# chỉ chạy khi có theme flatsome đi kèm
						elif [ -d "$d/wp-content/themes/flatsome" ]; then
							echoY "cleanup - - - webgiareorg..."
							remove_code_and_htaccess $d/wp-content/webgiareorg
							echoG "rsync - - - webgiareorg..."
							rsync -ah /root/wp-all-update/webgiareorg-main/* $d/wp-content/webgiareorg/ > /dev/null 2>&1
							#chown -R nginx:nginx $d/wp-content/webgiareorg
							
							# copy file index-tmp.php de active WP_ACTIVE_WGR_SUPPER_CACHE luon va ngay
							if [ -f "$d/wp-content/webgiareorg/index-tmp.php" ]; then
								echoG "active WP ACTIVE WGR SUPPER CACHE..."
								yes | cp -rf $d/wp-content/webgiareorg/index-tmp.php $d/index.php
							fi
						else
							echoR "webgiareorg for flatsome ONLY..."
						fi
					else
						echo "Update for Another code ONLY..."
					fi

					# dọn dẹp code dư thừa của backup
					echoY "Cleanup EB update code..."
					rm -rf $d/wp-content/echbaydotcom-*
					rm -rf $d/wp-content/themes/echbaytwo-*
					rm -rf $d/wp-content/webgiareorg-*
					# dọn dẹp file thừa do lỗi update của webgiareorg trước đây
					rm -rf $d/EB_THEME_CACHE-*
					
					# wordpres plugin -> chay vong lap va update tat ca neu co
					#if [ -d /root/wp-all-update/plugins ]; then
					if [ -d "$d/wp-content/plugins" ]; then
						#for d_plugins in /root/wp-all-update/plugins/*
						for d_plugins in $d/wp-content/plugins/*
						do
							if [ -d $d_plugins ]; then
								d_pl=$(basename $d_plugins)
								#echo $d_pl
								rsync_wp_plugin $d_pl $d ""
							fi
						done
					fi
					
					if [ ! "$4" == "" ]; then
						id -u $4
						if [ $? -eq 0 ]; then
							echo "chown user: "$4
							
							# voi DirectAdmin -> chuyen quyen cho user
							if [ -f /etc/init.d/directadmin ]; then
								chown -R $4:$4 $d
								chown -R $4:$4 $d/*
							else
								# voi VPSSIM, HOCVPS -> phan quyen cho user va nginx
								id -u nginx
								if [ $? -eq 0 ]; then
									chown -R $4:nginx $d
									chown -R $4:nginx $d/*
								else
									chown -R $4:$4 $d
									chown -R $4:$4 $d/*
								fi
							fi
						else
							echo "user "$4" not exist"
						fi
					fi
					
					echo "Rsync all DONE..."
					sleep 3;
				# thử xem có phải là laravel hoặc codeigniter không
				elif [ -f $d/code-mau.php ] && [ -d $d/app ] && [ -d $d/public ] && [ -d $d/system ]; then
					echo $d
					# tim duoc website wp
					echoY "++++++++++++++++++++++++++++ It is a Laravel or Codeigniter website"
					
					echoY "Begin cleanup... Please wait..."

					# dọn rác update trên này
					echo $d"/system-*"
					rm -rf $d/system-*

					echoG "Cleanup all DONE..."
					sleep 3;
				else
					#echo $d
					stt=$2
					let "stt+=1"
					#echo $stt
					get_all_dir_in_dir $d"/*" $stt $3 $4
				fi
			fi
		fi
	done
fi
}


# lap tim cac website trong thu muc home
WP_update_main(){
echoG "Check WP update in: "$DirSetup
#exit

# voi cac thu muc khac, quet thang trong thu muc
if [ ! "$DirSetup" == "/home" ]; then
	get_all_dir_in_dir $DirSetup"/*" 0 $MaxCheck $host_user
else

# voi thu muc home thi moi can do theo host
for d_home in $DirSetup/*
do
	# neu la thu muc -> tim cac file wp trong nay
	if [ -d $d_home ]; then
		echo "d home: "$d_home
		
		# tai khoan de chmod file sau khi update
		if [ "$chmodUser" == "" ]; then
			host_user=$(basename $d_home)
		else
			host_user=$chmodUser
		fi
		echo "host user: "$host_user
		
		get_all_dir_in_dir $d_home"/*" 0 $MaxCheck $host_user
		
		echo "========================================"
	fi
done

fi

}
WP_update_main

#
if [ ! "$re_download_plugin" == "" ]; then
echoY "Re-update after 10s"
sleep 10
WP_update_main
fi

#
cd ~
echo $(date) >> /root/update-wordpress-for-all-site-log.txt

#
if [ ! -f /tmp/server_wp_all_update ] && [ -f /home/vpssim.conf ]; then
/etc/vpssim/menu/vpssim-tien-ich
fi