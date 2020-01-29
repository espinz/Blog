#!/usr/bin/env bash

: << "END"
july 2, 2019.
The problem was the global variable latest_post. on a new day the variable is not set.
so findNouns has nothing to loop . for now i set it twice. once globally and one locally
July 11, 2019 - use git for these messages.
The clean up flag is broken: it is moving the source images directory into backup.
also put post into directories of that date.
Example: 2019/07/11/sitecleanup/
END

cmdarg="$#"
latest_post="$(grep -lR `date "+%Y-%m-%d"` /Users/Francisco/GitHub/Espinz/public/myblog/source/_posts/ | head -n 1)"

blogPost(){
    length=8
    printf -v line '%*s' "$length"
    echo ""
    printf "%s\n" "New Post"
    echo ${line// /-}
    
    echo -n "Title: "
    read title
    echo -n "Categories: "
    read category
    echo -n "Tags: "
    read tag
    today=`date "+%Y-%m-%d %H:00:00"`
    #   post=$date-$title.markdown
    post=$title.md
    postFormat="$(printf "%s" `echo "$post"| awk '{for(i=1;i<=NF;i++){ $i=tolower(substr($i,1,1)) substr($i,2) }}1'`)"
    #imageFormat="$(printf "%s" `echo "$title"`)"
    folder="/Users/Francisco/GitHub/Espinz/public/myblog/source/_posts"
    #    today=`date +"%m%d%y"`
    cd ${folder}
    cat << END > $postFormat
---
layout: post
title:  $title
date: $today
categories: [$category]
tags: [$tag]
toc: true
thumbnail: /images/imageFormat.jpg
published: true
---
END
    vim -s ~/Bin/source/vimNewPostMacro $postFormat
    read -r -p "Is this a draft? [y/N] " answer
    answer=${answer,,}
    if [ $answer == "y" ]; then
        sed -i '' -e s'/published: true/published: false/g' $latest_post
    else
        printf "Publish is set to true!\nUse new_post -p f to set to false.\n"
    fi
    cd ../..
    #git add . && git commit -am "$title"
    #bundle exec jekyll build && \
    #    rsync -pvru --delete /Users/fedev/GitHub/Espinz/public/dotCom/_site/* /Users/fedev/GitHub/Espinz/public/Home/
    
}


blogBuild(){
    cd /Users/Francisco/GitHub/Espinz/public/myblog
    if [ -z "$title" ]; then
        title=`git log --oneline| cut -d ' ' -f 2-3 | head -n 1`
        echo $title
    else
        echo $title
    fi
    printf "cd `pwd`\n"
    hexo g
    git add . && git commit -S -am "$title"
    #JEKYLL_ENV=production bundle exec jekyll build &&
    rsync -pvru --delete /Users/Francisco/GitHub/Espinz/public/myblog/public/* /Users/Francisco/GitHub/Espinz/public/Home/
    cd /Users/Francisco/GitHub/Espinz/public/Home/
    git add . && git commit -S -am "$title"
}

blogTest(){
    cd /Users/Francisco/GitHub/Espinz/public/myblog/
    hexo s
    #bundle exec jekyll serve &
    #sleep 4
    #/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome "http://localhost:4000"
    printf "\nDone.\n"
}

blogPush(){
    read -r -p "Would you like to upload the post? [y/N] " answer
    answer=${answer,,}
    case "$answer" in
        y)
            read -r -p "git message: " title
            cd /Users/Francisco/GitHub/Espinz/public/Home
            git add . && git commit -S -am "$title"
            git push
        ;;
        *)
            exit
        ;;
    esac
}

cleanImages(){
    myblog="/Users/Francisco/GitHub/Espinz/public/myblog"
    cd $myblog
    printf "changed into directory: `pwd`\n"
    sleep .5
    printf "updating recent posts.\n"
    sleep .5
    hexo list post > ${myblog}/recent.posts
    cd ${myblog}/source/_posts
    printf "changed into directory: `pwd`\n"
    sleep .5
    printf "detecting the 14th post.\n"
    sleep .5
    nthPost=$(cat ${myblog}/recent.posts| sort -r | grep "2019" | sed '15!d' | grep -Eo "_posts.*md" | sed s/_posts// | sed 's:/::')
    printf "removing image from the 14th post.\n"
    sleep .5
    currentImage=$(cat $nthPost | grep "thumbnail:" | awk {'print $2'} | sed s#/images/##)
    sed -i '' -e '/thumbnail/d' $nthPost
    mv ../images/${currentImage} ${myblog}/imagesBackup
    printf "Done!\n"
    sleep .5
}

findNouns(){
    read -r -p "Image grab? " answer
    answer=${answer,,}
    if [ $answer == 'y' ]; then
        printf "Adding images into array: ";
        for i in $(cat $latest_post); do
            #echo $i
            if [ ${#i} -gt 3 ]; then
                osx-dictionary -d "Dictionary" $i | grep -o "\ noun\ " > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    printf "."
                    myArray+=( "$i" )
                else
                    echo "not a noun" > /dev/null 2>&1
                fi
            fi
        done
        echo " "
        # echos full array
        
        duplicates=$(printf '%s\n' "${myArray[@]}"|awk '!($0 in seen){seen[$0];next} 1')
        myArray2=()
        for i in $duplicates; do
            myArray2+=( $i )
            echo "Adding duplicate: ${myArray2[@]}"
        done
        echo "Removing duplicates"
        myArray3=()
        for i in "${myArray[@]}"; do
            skip=
            for j in "${myArray2[@]}"; do
                [[ $i == $j ]] && { skip=1; break; }
            done
            [[ -n $skip ]] || myArray3+=("$i")
        done
        #declare -p Array3
        echo "Array completed: ${myArray3[@]}"
        
        total=`jot -r 1 1 ${#myArray3[@]}`
        echo "Array total count: ${#myArray3[@]}"
        random_picture=${myArray3[$total]}
        sed -i '' -e "s/imageFormat/$random_picture/" $latest_post
        #today=`date +%Y-%m-%d`
        images="/Users/Francisco/GitHub/Espinz/public/myblog/source/images"
        cd ${images}
        printf "Image grab has selected: ${random_picture}\n"
        curl --retry 5 -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36" \
        -L https://source.unsplash.com/daily?$random_picture > ${random_picture}.jpg
        sips -Z 640 ${random_picture}.jpg
        echo "Done!"
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
        
        
    else
        echo "Not grabbing image."
    fi
    cd ../..
}



if [ $cmdarg -lt 1 ]; then
    printf "usage: new_post [-n] [-u] [-b] [-t] [-e] [-p] [-i] [-c]\n"
    printf "\ncreate a newpost: -n\nupload to github: -u\nbuild and copy site: -b\ntest site: -t\nedit latest post: -e\ntoggle latest published: -p [t/F]\n"
    exit
else
    case $1 in
        -n)
            printf "Creating new post.\n"
            sleep 1
            blogPost
            latest_post="$(grep -lR `date "+%Y-%m-%d"` /Users/Francisco/GitHub/Espinz/public/myblog/source/_posts/ | head -n 1)"
            findNouns
            #findNouns
            cleanImages
            blogBuild
            blogTest
            read -r -p "Would you like to upload the post? " answer
            answer=${answer,,}
            if [ $answer == 'y' ]; then
                blogPush
            else
                exit
            fi
        ;;
        -b)
            printf "Building blog.\n"
            blogBuild
        ;;
        -u)
            printf "Uploading to gitHub\n"
            sleep .05
            blogPush
        ;;
        -t)
            printf "Testing development site now.\n"
            sleep .05
            blogTest
        ;;
        -e)
            printf "Editing latest post.\n"
            sleep .05
            vim $latest_post
        ;;
        -p)
            if [ $2 == "t" ]; then
                printf "Post toggled to true.\n"
                sleep .05
                sed -i '' -e s'/published: false/published: true/g' $latest_post
            else
                printf "Post toggled to false.\n"
                sed -i '' -e s'/published: true/published: false/g' $latest_post
            fi
        ;;
        -i)
            findNouns
        ;;
        -c)
            cleanImages
        ;;
        *)
            exit
        ;;
    esac
fi