#!/usr/bin/bash

# 지역변수 셋팅
system_file="/data/work/system_download.txt"
conf_dir=$1
data_dir=$(cat ${system_file} | grep postgresql_data_directory | awk -F '|' '{print $2}')
file_name=$(find ${conf_dir} -type f -name "*postgresql.conf*")

# 데이터 디렉토리 생성
mkdir -p ${data_dir}
# 소유권 변경
chown -R postgres:postgres ${data_dir}

# db 초기화
sudo -u postgres /usr/lib/postgresql/12/bin/initdb -D ${data_dir} --encoding='utf8' --locale='ko_KR.UTF-8' --lc-collate='ko_KR.UTF-8' --lc-ctype='ko_KR.UTF-8' --lc-messages='en_US.UTF8'
# 초기화시 생성된 설정파일 삭제
sudo -u postgres rm -f ${data_dir}/*.conf

# postgresql 설정 파일 동적 setup
postgresql_config=$(awk '/\[postgresql.conf-start\]/{flag=1; next} /\[postgresql.conf-end\]/{flag=0} flag' ${system_file})
while IFS= read -r postgresql_config_low; do
        postgre_config_name=$(echo $postgresql_config_low | awk -F '|' '{print $1}' | sed 's/[][]//g')
        postgre_config_value=$(echo $postgresql_config_low | awk -F '|' '{print $2}')
        sed -i "s|^${postgre_config_name}.*$|${postgre_config_name} = ${postgre_config_value}|" ${file_name}
done <<< "$postgresql_config"
