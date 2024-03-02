set -e

function make_pg_dump(){
    IFS=' ' read -r -a array <<< $1
    host=""
    dbname=""
    user=""
    password=""
    for element in "${array[@]}"
    do
        IFS='=' read -r -a pair <<< "$element"
        key="${pair[0]}"
        value="${pair[1]}"
        case $key in
            host)
                host=$value
                ;;
            dbname)
                dbname=$value
                ;;
            user)
                user=$value
                ;;
            password)
                password=$value
                ;;
        esac
    done
    cmd='pg_dump postgres://'$user':'$password'@'$host':5432/'$dbname' -f /storage/pg_dump.sql'
    $cmd
    return 
}

TIMESTAMP_FILE=./turkey-pack-n-go_ts.tmp
MAX_CALLS=900
TIME_LIMIT=550
touch $TIMESTAMP_FILE
ratelimiter() {
    printf "\n>>"
    sleep 1
    return
    local current_time=$(date +%s)
    # Read the timestamp file and remove records that are older than 10 minutes
    awk -v limit=$((current_time - TIME_LIMIT)) '$1 > limit' $TIMESTAMP_FILE > ${TIMESTAMP_FILE}_tmp && mv ${TIMESTAMP_FILE}_tmp $TIMESTAMP_FILE
    local call_count=$(wc -l < $TIMESTAMP_FILE)
    if (( call_count >= MAX_CALLS )); then
        local oldest_timestamp=$(head -n 1 $TIMESTAMP_FILE)
        local sleep_time=$((oldest_timestamp + TIME_LIMIT - current_time))
        echo "cool down ($sleep_time)"
        sleep $sleep_time
        ratelimiter
        return
    else
        echo $current_time >> $TIMESTAMP_FILE
        echo ">>"
    fi
}


backupName="legacyhc"

# 2 required inputs
echo "turkeyauthtoken:" && read turkeyauthtoken
echo -e "using turkeyauthtoken: $turkeyauthtoken \n"
echo "native-hub-domain (ie: foobar.myhubs.net):" && read hubdomain
echo -e "using hubdomain: $hubdomain \n"

# update psql
sudo sh -c 'echo "deb http://apt-archive.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null
sudo apt update
sudo apt install postgresql -y

# dump db
! [ -f /storage/pg_dump.sql ] && dbCreds=$(cat /hab/svc/pgbouncer/config/pgbouncer.ini | grep -e 'polycosm_production = ') && make_pg_dump "$dbCreds"

# upload
echo "" > filelist
find "/storage" -type f -print0 | while IFS= read -r -d '' file; do
    echo "$file" >> filelist
done
for f in $(cat filelist); do
    ratelimiter
    printf "\n uploading: $f..."
    curl -s -o /dev/null -w "%{http_code}" -X POST -F "file=@$f" -H "turkeyauthtoken:$turkeyauthtoken" -H "addpath:/$backupName/$(dirname $f)" https://$hubdomain/api/ita/upload
    sleep 1
done

# call to restore with phx_secret
secret_key=$(cat /hab/svc/reticulum/config/config.toml | grep -e 'secret_key = ' | sed 's/secret_key = //'|tr -d '"')
secret_key_base=$(cat /hab/svc/reticulum/config/config.toml | grep -e 'secret_key_base = ' | sed 's/secret_key_base = //'|tr -d '"')

echo -e "\n---\n start restoring... \n"
curl -H "turkeyauthtoken:$turkeyauthtoken" -H "secret_key:$secret_key" -H "secret_key_base:$secret_key_base" https://$hubdomain/api/ita/restore?backupName=$backupName

