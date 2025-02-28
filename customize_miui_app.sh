#/bin/bash

XMLMERGYTOOL=$PORT_ROOT/tools/ResValuesModify/jar/ResValuesModify
GIT_APPLY=$PORT_ROOT/tools/git.apply

curdir=`pwd`

function applyPatch () {
    for patch in `find $1 -name "*.patch"`
    do
        cd out
        $GIT_APPLY ../$patch
        cd ..
        for rej in `find $2 -name *.rej`
        do
            echo "Patch $patch fail"
            exit 1
        done
    done
}

function appendSmaliPart() {
    for file in `find $1/smali -name *.part`
    do
		filepath=`dirname $file`
		filename=`basename $file .part`
		dstfile="out/$filepath/$filename"
        cat $file >> $dstfile
    done
}

function mergyXmlPart() {
	for file in `find $1/res -name *.xml.part`
	do
		src=`dirname $file`
		dst=${src/$1/$2}
		$XMLMERGYTOOL $src $dst
	done
}

if [ $1 = "InCallUI" ];then
    $XMLMERGYTOOL $1/res/values $2/res/values
fi

if [ $1 = "MiuiHome" ];then
    applyPatch $1 $2
    $XMLMERGYTOOL $1/res/values $2/res/values
    sed -i '/- 16/a\  - 27\nsdkInfo:\n  minSdkVersion: '\''23'\''\n  targetSdkVersion: '\''23'\''' $2/apktool.yml
fi

if [ $1 = "MiuiSystemUI" ];then
    applyPatch $1 $2
    $XMLMERGYTOOL $1/res/values $2/res/values
fi

if [ $1 = "Mms" ];then
    applyPatch $1 $2
    sed -i '/  - 16/a\  - 18' $2/apktool.yml
fi

if [ $1 = "SecurityCenter" ];then
    applyPatch $1 $2
    sed -i '/- 16/a\sdkInfo:\n  minSdkVersion: '\''23'\''\n  targetSdkVersion: '\''23'\''' $2/apktool.yml
fi

if [ $1 = "Settings" ];then
    applyPatch $1 $2
fi

if [ $1 = "XiaomiAccount" ];then
    applyPatch $1 $2
    sed -i '/- 16/a\sdkInfo:\n  minSdkVersion: '\''23'\''\n  targetSdkVersion: '\''23'\''' $2/apktool.yml
fi
