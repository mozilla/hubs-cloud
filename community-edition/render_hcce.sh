
bins=("bash" "openssl" "npm")
for cmd in "${bins[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        echo "missing required binary: $cmd"
        return 1
    fi
done

if ! npm list -g pem-jwk | grep -q pem-jwk; then
    echo "missing required npm pkg: pem-jwk, try (sudo) npm install pem-jwk -g to install it"
    return 1
fi


### required
export HUB_DOMAIN="example.net"
export ADM_EMAIL="admin@example.net"

export Namespace="hcce"

export DB_USER="postgres"
export DB_PASS="123456"
export DB_NAME="retdb"
export DB_HOST="pgbouncer"
export DB_HOST_T="pgbouncer-t"
export PGRST_DB_URI="postgres://$DB_USER:$DB_PASS@pgbouncer/$DB_NAME"
export PSQL="postgres://$DB_USER:$DB_PASS@pgbouncer/$DB_NAME"

export SMTP_SERVER="changeMe"
export SMTP_PORT="changeMe"
export SMTP_USER="changeMe"
export SMTP_PASS="changeMe"

export NODE_COOKIE="changeMe"
export GUARDIAN_KEY="changeMe"
export PHX_KEY="changeMe"

export SKETCHFAB_API_KEY="?"
export TENOR_API_KEY="?"



### dev only keys
# export PERMS_KEY='-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCerz7tPxgtwm2M\\nSFVrh+0bYzLiIo/s83xuCreKL5feMnJWoV3dhjNRhvZCsi5yNdDVZQzfe8t2dmse\\nujxtP1O1Pmg5alEksGzEHjLtxboVn4lRhkkQ2L1Rle2Cr0neLUjLfV0ek+agxxWR\\n62pNUjSxDua+gW/Uq8VveEMqLQGIRGFiAjI89cXdthW8imV32NyrIPce9WKyL3Us\\nLPXUmZwzOTV9/0U14SJm848W0DDckBQECpEG0MTmLn29J4Sq4EEky6QUD7GPkIGT\\nHRhFRQEc4lgMH7Rgo1zH1HbwUCgG9bH4iPteViBrPC3SnSVsXrUO3alH1Gv56Zpe\\nQs6FHm7HAgMBAAECggEASh+IIGBJlg5tB4s+Q3WB3zouKY2Fd2ShKfHdnDHxGbys\\nxiSoaPLoA9wsKil7IqRawWNraPU1rEdScE8ELO/Y1R+qpa8w6hdzJwUIOyMScklM\\nZoV4meL0RCjpghMJSTwT9eHAXqktoMp+G+RAio+sx0wzoqdpqoj2N8SQcyIExjaW\\nWK3Na0D0ARWX5e6bmgJNoOcaJjW9eKX/m/nRgnUkJG7lNic1szXhSHJY4j/mLn+E\\nH1zIaZDVpgXA6RG8YEO9QHfJTAFsEvEO2shjVlswOBD9++FNsM69fLUE6THBugJx\\n5PtM8LdjXiFHO5G8z7BmBZWeY/s+dyfKL59UB40yKQKBgQDTUQzWnLol3jEmtuRh\\nSfJersNDNtblyX2v7uXPqUkH1yY7+GQKCh9R4to8zBXPp9FMB6tiCZ2+syP9ZJK3\\nIQZiqHpdR1zZOFHDbDr63hDuNbkEkACRDA6zhssyVFWeYSadhaS5lFA1CjSrSDZ9\\np+NRSFfpLrJQQ7rdpbNNTJ0SdQKBgQDAPSCw/Uutwy3bA8EdVjdxm45a6SpSzyBe\\nxjwXAXjQjmQG0Vu+m8rgE2jUNucIGcdhh6yp46Q95QHuLhg09P+QD4vw8aeYzuK9\\nnjaqrB0ynH3C7rOgHTWRs51JaFW7IVziBygLMukkvb0Qc+5qrRlKyeD6Bz2ZrAuN\\nr+BDktwcywKBgQCcDpwrlh0GwDuOOr0YeDLM58V+Su6TTqVKm2QOYxdy+dnbqgm/\\nPFB6+cxv38wvyeCQhI113mInpkZq6K5NHc+IZqHPZ1dTd/syFijMgdkBAp27l9lD\\nRSNKQ76mUY/VYivRYxQOlVBSi1HwOGk9jRIcQg/iPkEjc5F6BNgQuwa4zQKBgAgG\\nhUbeTDqE23U5QuamosnrZJYHBe1PGFrci8WqGhEa4LIoK1xZxK52IPo7EIoWCWzY\\n7SxqhIDQ/rOi2P/c+o5ZF86HSCfo+y5PXJjjdpSWU+m/bWBR19qtVPOrl2ioi+gj\\nxFgzV+hgw3PcYyew8k1dADdv9fJkbFcN8J7hkq7hAoGAWWCIX0N8K/u6Qy7YYgTg\\nmNJqXusFDQFGizM6A3mfziIpMi9vsUDNY4D7VHwIKStbei78Jf/Em3MyxxNAb78z\\nW0hs6TeiTgbZQFBcktrDoDGQ34kZ/1jIFS1c2M/VfydvAdo36aB03SU6G0oWIlYk\\nxBclLooIqHBPs/bnYHu4xeM=\\n-----END PRIVATE KEY-----\\n'
# export PGRST_JWT_SECRET='{"kty":"RSA","n":"uFXP_Vd35BAEs11XTlkxBIY84FFPCpY8rz-zcSW9GmsGCLsJdZupWsKyXLyW3oHdmXDIoOan5LWrI455ZUnrIQ2EjTJ1owcvSyeYBZ2Fc0tyf3JxE8kHf9dD4w8abczojDn0gSfXuyloxxDnTt50kKx2QVIg3Le4Jzbsxmg1G6RwKKN-Mg3PwrLvAvV7MOfwvSUelKoEEh7WSaqHnTfMtD502bTQ93Kof7n-fr42PUIsWrXsJ_WqPE2bZXdKOM8T3tUe7c-voITZAB7IbCZFwXBa1AVBo8QaUy6ci9C8R6ZTVFo7Xqbv8p8OfZFHk_yTqlSwiBKvDPymBlZPUZMRZw","e":"AQAB"}'

###
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
export PERMS_KEY="$(echo -n "$(awk '{printf "%s\\\\n", $0}' private_key.pem)")"
openssl ec -pubout -in private_key.pem -out public_key.pem
#sudo apt-get install npm && sudo npm install -g pem-jwk
export PGRST_JWT_SECRET=$(pem-jwk public_key.pem)

### initial cert
openssl req -x509 -newkey rsa:2048 -sha256 -days 36500 -nodes -keyout key.pem -out cert.pem -subj '/CN='$HUB_DOMAIN
export initCert=$(base64 -i cert.pem | tr -d '\n')
export initKey=$(base64 -i key.pem | tr -d '\n')


read -p "Do you want to use persistent volumes? (y/N): " use_persistent_answer
if [[ $use_persistent_answer =~ ^[Yy]$ ]]; then
    envsubst < "persist.yam" > "$Namespace.yaml"
else
    envsubst < "hcce.yam" > "$Namespace.yaml"
fi