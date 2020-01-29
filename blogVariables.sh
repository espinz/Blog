# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

FOUND="${GREEN}Found!${NOCOLOR}"

cmdarg="$#"
ram_disk="/Volumes/RAMDisk"
blog_home="/Users/Francisco/GitHub/Espinz/public/myblog"
blog_posts="${blog_home}/source/_posts"
blog_images="${blog_home}/source/images"
latest_blog="$(cat ${ram_disk}/recent.posts | tail -n 2 | grep -E "[0-9]"| grep -Eo "_posts.*md" | sed s/_posts// | sed 's:/::')"
#latest_post="$(grep -lR `date "+%Y-%m-%d"` $blog_posts | head -n 1)"
category_choices=""
#source `which virtualenvwrapper.sh`
#workon automation_cookbook