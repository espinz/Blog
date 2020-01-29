source /Users/Francisco/Bin/source/blogVariables.sh

blogMenu() {
    menu_choices=$(dialog --stdout --menu 'Please pick a category' 0 0 0 1 computer 2 os 3 terminal 4 unique 5 website)

    case "$menu_choices" in
    1)
        menu_choices=$(dialog --stdout --menu 'Please pick a category' 0 0 0 1 hardware 2 languages)
        if [ $menu_choices == 1 ]; then
            category_choices="computer, hardware"
        else
            category_choices="computer, languages"
        fi
        ;;
    2)
        menu_choices=$(dialog --stdout --menu 'Please pick a category' 0 0 0 1 linux 2 macos 3 windows)
        if [ $menu_choices == 1 ]; then
            category_choices="os, linux"
        elif [ $menu_choices == 2 ]; then
            category_choices="os, macos"
        else
            category_choices="os, windows"
        fi
        ;;
    3)
        menu_choices=$(dialog --stdout --menu 'Please pick a category' 0 0 0 1 shell)
        if [ $menu_choices == 1 ]; then
            category_choices="terminal, shell"
        fi
        ;;
    4)
        menu_choices=$(dialog --stdout --menu 'Please pick a category' 0 0 0 1 thought)
        if [ $menu_choices == 1 ]; then
            category_choices="unique, thought"
        fi
        ;;
    5)
        menu_choices=$(dialog --stdout --menu 'Please pick a category' 0 0 0 1 updates)
        if [ $menu_choices == 1 ]; then
            category_choices="website, updates"
        fi
        ;;
    *)
        echo "exit"
        ;;
    esac

}
blogPost() {
    cd ${blog_posts}
    # hexo new "HelloWorld" -p "recipes/ssh"
    length=8
    printf -v line '%*s' "$length"
    echo ""
    printf "%s\n" "New Post - $category_choices"
    echo ${line// /-}

    echo -n "Title: "
    read title
    find . -type d -maxdepth 1
    echo -n "Directory: "
    read hex_directory
    echo -n "Tags: "
    read tag
    today=$(date "+%Y-%m-%d %H:00:%S")
    #   post=$date-$title.markdown
    post=$title.md
    postFormat="$(printf "%s" $(echo "$post" | awk '{for(i=1;i<=NF;i++){ $i=tolower(substr($i,1,1)) substr($i,2) }}1'))"
    #postFormat="$(printf "%s" `echo "$post"`)"
    #imageFormat="$(printf "%s" `echo "$title"`)"

    #    today=`date +"%m%d%y"`
    #hexo new $title -p "$hex_directory/$title"
    mkdir $hex_directory
    cd $hex_directory
    cat <<END > $postFormat
---
layout: post
title:  $title
date: $today
categories: [$category_choices]
tags: [$tag]
toc: true
thumbnail: /images/imageFormat.jpg
published: true
---
END
    vim -s ~/Bin/source/vimNewPostMacro $postFormat
    #git add . && git commit -am "$title"
    #bundle exec jekyll build && \
    #    rsync -pvru --delete /Users/fedev/GitHub/Espinz/public/dotCom/_site/* /Users/fedev/GitHub/Espinz/public/Home/

}

blogBackup() {
    cd $blog_home
    image=$(git status | grep jpg | head -n 1 | awk {'print $2'} | sed s/'source\/images\/'//)
    mv imagesBackup/$image $blog_images/$image
}
blogDraft() {
    read -r -p "Is this a draft? [y/N] " answer
    answer=${answer,,}

    if [ $answer == "y" ]; then
        latest_post="$(grep -lR $(date "+%Y-%m-%d") /Users/Francisco/GitHub/Espinz/public/myblog/source/_posts | head -n 1)"
        cd $blog_posts
        # sed -i '' -e "s/imageFormat/$random_picture/" $latest_post
        #echo "latest: $latest_post"
        sed -i '' -E "s/published: true/published: false/" $latest_post
    else
        printf "Publish is set to true!\nUse new_post -p f to set to false.\n"
    fi
}
blogBuild() {
    cd $blog_home
    if [ -z "$title" ]; then
        title=$(git log --oneline | cut -d ' ' -f 2-3 | head -n 1)
        echo $title
    else
        echo $title
    fi
    printf "cd $(pwd)\n"
    hexo g
    git add . && git commit -S -am "$title"
    #JEKYLL_ENV=production bundle exec jekyll build &&
    rsync -pvru --delete /Users/Francisco/GitHub/Espinz/public/myblog/public/* /Users/Francisco/GitHub/Espinz/public/Home/
    cd /Users/Francisco/GitHub/Espinz/public/Home/
    git add . && git commit -S -am "$title"
}

blogTest() {
    cd $blog_home
    hexo s
    #bundle exec jekyll serve &
    #sleep 4
    #/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome "http://localhost:4000"
    printf "\nDone.\n"
}

blogPush() {
    read -r -p "Would you like to upload the post? [y/N] " answer
    answer=${answer,,}
    case "$answer" in
    y)
        read -r -p "git message: " title
        cd $blog_home
        git add . && git commit -S -am "$title"
        git push
        ;;
    *)
        exit
        ;;
    esac
}

findNouns() {
    read -r -p "Download image? [Y/n] " question
    question=${question,,}
    if [ $question == 'y' ]; then
        read -r -p "Would you like to enter an image keyword? [Y/n] " keyword
        keyword=${keyword,,}
        myArray=()
        myArray2=()
        myArray3=()
        random_picture=""

        if [ $keyword == 'y' ]; then
            sleep .25
            read -r -p "Image Keyword: " keyword
            myArray3+=("$keyword")
            random_picture="${myArray3[@]}"
        else
            echo "No selected."
            sleep .25
            printf "Grabbing keywords from post: "
            for i in $(cat $latest_post); do
                #echo $i
                if [ ${#i} -gt 3 ]; then
                    osx-dictionary -d "Dictionary" $i | grep -o "\ noun\ " >/dev/null 2>&1
                    if [ $? -eq 0 ]; then
                        printf "."
                        myArray+=("$i")
                    else
                        echo "not a noun" >/dev/null 2>&1
                    fi
                fi
            done
            echo " "
            # echos full array
            echo "Array completed: ${myArray[@]}"
            duplicates=$(printf '%s\n' "${myArray[@]}" | awk '!($0 in seen){seen[$0];next} 1')

            for i in $duplicates; do
                myArray2+=($i)
                echo ${myArray2[@]}
            done
            echo "Removing duplicates"
            for i in "${myArray[@]}"; do
                skip=
                for j in "${myArray2[@]}"; do
                    [[ $i == $j ]] && {
                        skip=1
                        break
                    }
                done
                [[ -n $skip ]] || myArray3+=("$i")
            done
            #declare -p Array3
            total=$(jot -r 1 1 ${#myArray3[@]})
            random_picture="${myArray3[$total]}"
        fi

        # echo "Array completed: ${myArray3[@]}"
        # echo "Array total count: ${#myArray3[@]}"

        # echo "Random picture: $random_picture"

        if [ -z $latest_post ]; then
            cd $blog_posts
            sed -i '' -e "s/imageFormat/$random_picture/" $latest_blog
        else
            sed -i '' -e "s/imageFormat/$random_picture/" $latest_post
        fi
        #today=`date +%Y-%m-%d`
        cd ${blog_images}
        printf "Image grab has selected: ${random_picture}\n"
        # replace imageFormat from blogPost function via sed
        # use $random_picture
        #cat $latest_post
        # exit
        # if [ -Z "$image_format" ]; then
        #    imageFormat=$random_picture
        #else
        #    echo "using: $imageFormat"
        #fi

        # end replace checking......

        curl -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36" \
            -L https://source.unsplash.com/random?$random_picture >${random_picture}.jpg
        sips -Z 640 ${random_picture}.jpg
    else
        echo "Not downloading image."
    fi
}

cleanImages() {
    cd $blog_home
    printf "${ORANGE}Changing directory:${NOCOLOR} $(pwd)\n"
    sleep .5

    printf "${GREEN}Updating Hexo posts list${NOCOLOR}\n"
    hexo list post >${ram_disk}/recent.posts
    sleep .5

    printf "${BLUE}Detecting the 14th post${NOCOLOR}\n"
    nthPost="$(cat ${ram_disk}/recent.posts | grep -v "Draft" | sort -r | grep "2019" | sed '15!d' | grep -Eo "_posts.*md" | sed s/_posts// | sed 's:/::')"
    printf "${GREEN}Found:${NOCOLOR} $nthPost\n"
    sleep .5

    cd ${blog_posts}
    echo -e "${ORANGE}Changing directory:${NOCOLOR} $(pwd)"

    echo -e "${GREEN}Extracting post image.${NOCOLOR}"
    foundImage="$(cat $nthPost | grep "thumbnail:" | awk {'print $2'} | sed s\#/images/\#\#)"

    if [ -n $foundImage ]; then
        echo "Found image: $foundImage"
        sed -i '' -e '/thumbnail/d' $nthPost
        echo "Done."
        sleep .5
        echo "Backing up 16th image."
        mv ${blog_images}/${foundImage} ${blog_home}/images/imagesBackup
        printf "Cleaning complete!\n"
        sleep .5
    else
        echo -e "${RED}No thumbnail found in $nthPost${NOCOLOR}"
        exit
    fi

}

mkSyms() {
    cd $blog_home
    unlink latestPost.md
    latest_post="$(hexo list post | grep -v Draft | tail -n1 | grep -Eo "_posts.*md" | sed s/_posts// | sed 's:/::')"
    #latest_post=`ls -l source/_posts | grep $(date | awk {'print $2'}) | sort -k 7 | tail -n 1 | awk {'print $9'}`
    ln -s $blog_posts/$latest_post latestPost.md
}
