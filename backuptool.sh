#!/sbin/sh
#
# Backup and restore proprietary Android system files
#

C=/cache
S=/system

get_files() {
    cat <<EOF
app/BugReport.apk
app/CarDock.apk
app/com.amazon.mp3.apk
app/EnhancedGoogleSearchProvider.apk app/GoogleSearch.apk
app/Facebook.apk
app/GenieWidget.apk
app/Gmail.apk
app/GmailProvider.apk
app/GoogleApps.apk
app/GoogleBackupTransport.apk
app/GoogleCheckin.apk
app/GoogleContactsSyncAdapter.apk
app/GoogleGoggles.apk
app/GooglePartnerSetup.apk
app/GoogleSettingsProvider.apk
app/GoogleSubscribedFeedsProvider.apk
app/googlevoice.apk
app/gtalkservice.apk
app/HtcCopyright.apk
app/LatinImeTutorial.apk
app/Maps.apk
app/MarketUpdater.apk
app/MediaUploader.apk
app/NetworkLocation.apk
app/PassionQuickOffice.apk
app/SetupWizard.apk app/Provision.apk
app/Street.apk
app/Talk.apk
app/TalkProvider.apk
app/Vending.apk
app/VoiceSearchWithKeyboard.apk app/LatinIME.apk
app/YouTube.apk
etc/permissions/com.google.android.datamessaging.xml
etc/permissions/com.google.android.gtalkservice.xml
etc/permissions/com.google.android.maps.xml
framework/com.google.android.gtalkservice.jar
framework/com.google.android.maps.jar
lib/libgtalk_jni.so
lib/libinterstitial.so
EOF
}

backup_file() {

   if [ ! -e "$C/google" ];
   then
         mkdir -p $C/google;
   fi

   if [ -e "$1" ];
   then
      if [ -n "$2" ];
      then
         echo "$2  $1" | md5sum -c -
         if [ $? -ne 0 ];
         then
            echo "MD5Sum check for $1 failed!";
            exit $?;
         fi
      fi
      
      local F=`basename $1`
      
      # dont backup any apps that have odex files, they are useless
      if ( echo $F | grep -q "\.apk$" ) && [ -e `echo $1 | sed -e 's/\.apk$/\.odex/'` ];
      then
         echo "Skipping odexed apk $1";
      else
         cp $1 $C/google/$F
      fi
   fi
}

restore_file() {
   local FILE=`basename $1`
   local DIR=`dirname $1`
   if [ -e "$C/google/$FILE" ];
   then
      if [ ! -d "$DIR" ];
      then
         mkdir -p $DIR;
      fi
      cp -p $C/google/$FILE $1;
      if [ -n "$2" ];
      then
         rm $2;
      fi
   fi
}

case "$1" in
   backup)
      mount $S
      mount $C
      get_files | while read FILE REPLACEMENT; do
         backup_file $S/$FILE
      done
   ;;
   restore)
      get_files | while read FILE REPLACEMENT; do
         R=""
         [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
         restore_file $S/$FILE $R
      done
   ;;
   *)
      echo "Usage: $0 {backup|restore}"
      exit 1
esac

exit 0
