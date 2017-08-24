#!/bin/bash
## This takes the work done in parser
## and merges it all into one

## Variables
SCRIPTBASEFILENAME=$(echo `basename $0 | cut -f 1 -d '.'`)
script_dir=$(dirname $0)
SCRIPTVARSDIR="$script_dir"/../../scriptvars/
STATICVARS="$SCRIPTVARSDIR"staticvariables.var
if
[[ -f $STATICVARS ]]
then
source $STATICVARS
else
echo "Static Vars File Missing, Exiting."
exit
fi

RECENTRUN="$LISTGENSCRIPTSLOGDIR""$SCRIPTBASEFILENAME".log

WHATITIS="All Parsed List"
timestamp=$(echo `date`)
if
[[ -f $BIGAPL ]]
then
rm $BIGAPL
echo "* $WHATITIS Removed. $timestamp" | tee --append $RECENTRUN &>/dev/null
else
echo "* $WHATITIS Not Removed. $timestamp" | tee --append $RECENTRUN &>/dev/null
fi

## Combine Small lists
printf "$yellow"  "Merging Individual Lists."
if
ls $PARSEDLISTSALL &> /dev/null;
then
cat $PARSEDLISTSALL >> $TEMPFILE
echo -e "`wc -l $TEMPFILE | cut -d " " -f 1` lines after merging individual lists"
else
printf "$red"  "No Parsed Files Available To Merge."
touch $TEMPFILE
INDIVIDUALMERGEFAILED=true
fi
echo ""

## Duplicate Removal
if
[[ -z $INDIVIDUALMERGEFAILED ]]
then
printf "$yellow"  "Removing duplicates."
cat -s $TEMPFILE | sort -u | gawk '{if (++dup[$0] == 1) print $0;}' >> $FILETEMP
echo -e "`wc -l $FILETEMP | cut -d " " -f 1` lines after deduping"
mv $FILETEMP $TEMPFILE
echo ""
fi

if
[[ -f $TEMPFILE ]]
then
ALLPARSEDSIZEBYTES=$(stat -c%s "$TEMPFILE")
ALLPARSEDSIZEKB=`expr $ALLPARSEDSIZEBYTES / 1024`
ALLPARSEDSIZEMB=`expr $ALLPARSEDSIZEBYTES / 1024 / 1024`
echo "ALLPARSEDSIZEMB="$ALLPARSEDSIZEMB"" | tee --append $TEMPVARS &>/dev/null
fi

if
[[ "$ALLPARSEDSIZEMB" -gt 0 && "$ALLPARSEDSIZEKB" -gt 0 && "$ALLPARSEDSIZEBYTES" -gt 0 ]]
then
printf "$yellow"  "Size of $BASEFILENAME = $ALLPARSEDSIZEMB MB."
elif
[[ "$ALLPARSEDSIZEMB" -eq 0 && "$ALLPARSEDSIZEKB" -gt 0 && "$ALLPARSEDSIZEBYTES" -gt 0 ]]
then
printf "$yellow"  "Size of $BASEFILENAME = $ALLPARSEDSIZEKB KB."
elif
[[ "$ALLPARSEDSIZEMB" -eq 0 && "$ALLPARSEDSIZEKB" -eq 0 && "$ALLPARSEDSIZEBYTES" -gt 0 ]]
then
printf "$yellow"  "Size of $BASEFILENAME = $ALLPARSEDSIZEBYTES Bytes."
fi

if
[[ "$ALLPARSEDSIZEBYTES" -gt 0 ]]
then
PARSEDHOWMANYLINES=$(echo -e "`wc -l $TEMPFILE | cut -d " " -f 1`")
printf "$yellow"  "$PARSEDHOWMANYLINES Lines After Compiling."
fi

if
[[ -f $BIGAPL && "$ALLPARSEDSIZEBYTES" -gt 0 ]]
then
printf "$green"  "Old BIGAPL File Removed."
rm $PARSEDFILE
fi

## Github has a 100mb limit, and empty files are useless
if 
[[ "$ALLPARSEDSIZEBYTES" -eq 0 ]]
then
printf "$red"     "File Empty"
echo "* Allparsedlist list was an empty file $timestamp" | tee --append $RECENTRUN &>/dev/null
mv $TEMPFILE $BIGAPL
elif
[[ "$ALLPARSEDSIZEMB" -ge "$GITHUBLIMITMB" ]]
then
printf "$red"     "Parsed File Too Large For Github. Deleting."
echo "* Allparsedlist list was too large to host on github. $FETCHFILESIZE bytes $timestamp" | tee --append $RECENTRUN &>/dev/null
mv $TEMPFILE $BIGAPL
elif
[[ "$ALLPARSEDSIZEMB" -lt "$GITHUBLIMITMB" && -f $BPARSEDFILETEMP ]]
then
mv $TEMPFILE $BIGAPL
printf "$yellow"  "Big List Created Successfully."
fi
